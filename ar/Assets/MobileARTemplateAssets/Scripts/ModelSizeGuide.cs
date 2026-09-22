using UnityEngine;
using TMPro;

public class ModelSizeGuide : MonoBehaviour
{
    [Header("연결 설정")]
    public Transform visualBox;
    public LineRenderer guideLine;
    public TextMeshProUGUI widthText;
    public TextMeshProUGUI heightText;
    public TextMeshProUGUI depthText;

    [Header("세부 조절")]
    public float floorOffset = 0.015f;
    public float textOffset = 0.05f;

    private GameObject targetModel;
    private Camera mainCamera;

    private Vector3 cachedLocalSize;
    private Vector3 cachedLocalCenter;
    private bool sizeCalculated = false;

    void Start()
    {
        mainCamera = Camera.main;
        if (transform.parent != null)
            targetModel = transform.parent.gameObject;

        CacheModelSize();
    }

    public void RecalculateSize()
    {
        sizeCalculated = false;
        CacheModelSize();
    }

    private void CacheModelSize()
    {
        if (targetModel == null) return;

        Transform t = targetModel.transform;
        Quaternion originalRot = t.rotation;

        t.rotation = Quaternion.identity;
        Bounds worldBounds = GetCombinedWorldBounds(targetModel);
        t.rotation = originalRot;

        if (worldBounds.size == Vector3.zero) return;

        Vector3 ls = t.lossyScale;
        cachedLocalSize = new Vector3(
            ls.x != 0 ? worldBounds.size.x / Mathf.Abs(ls.x) : 0,
            ls.y != 0 ? worldBounds.size.y / Mathf.Abs(ls.y) : 0,
            ls.z != 0 ? worldBounds.size.z / Mathf.Abs(ls.z) : 0
        );

        Vector3 worldOffset = worldBounds.center - t.position;
        cachedLocalCenter = new Vector3(
            ls.x != 0 ? worldOffset.x / ls.x : 0,
            ls.y != 0 ? worldOffset.y / ls.y : 0,
            ls.z != 0 ? worldOffset.z / ls.z : 0
        );

        sizeCalculated = true;
    }

    void LateUpdate()
    {
        if (targetModel == null || !sizeCalculated) return;
        if (mainCamera == null) mainCamera = Camera.main; // 카메라 재확인
        UpdateGuide();
    }

    private void UpdateGuide()
    {
        Transform t = targetModel.transform;
        Vector3 ls = t.lossyScale;

        Vector3 worldSize = new Vector3(
            cachedLocalSize.x * Mathf.Abs(ls.x),
            cachedLocalSize.y * Mathf.Abs(ls.y),
            cachedLocalSize.z * Mathf.Abs(ls.z)
        );

        Vector3 worldCenter = t.position + t.TransformVector(cachedLocalCenter);

        // ── VisualBox ──
        if (visualBox != null)
        {
            visualBox.position = worldCenter;
            visualBox.rotation = t.rotation;

            Transform vbParent = visualBox.parent;
            Vector3 parentLossy = vbParent != null ? vbParent.lossyScale : Vector3.one;
            visualBox.localScale = new Vector3(
                parentLossy.x != 0 ? worldSize.x / Mathf.Abs(parentLossy.x) : worldSize.x,
                parentLossy.y != 0 ? worldSize.y / Mathf.Abs(parentLossy.y) : worldSize.y,
                parentLossy.z != 0 ? worldSize.z / Mathf.Abs(parentLossy.z) : worldSize.z
            );
        }

        // ── 카메라 상대 위치 판별 (핵심 추가 부분) ──
        Vector3 right = t.right;
        Vector3 up = t.up;
        Vector3 forward = t.forward;

        float halfW = worldSize.x * 0.5f;
        float halfH = worldSize.y * 0.5f;
        float halfD = worldSize.z * 0.5f;

        // 카메라의 위치를 모델의 로컬 좌표계로 변환
        Vector3 localCamPos = t.InverseTransformPoint(mainCamera.transform.position);

        // 카메라가 모델을 기준으로 어느 사분면에 있는지 부호(+, -)를 추출
        float signX = localCamPos.x >= 0 ? 1f : -1f;
        float signZ = localCamPos.z >= 0 ? 1f : -1f;

        // 카메라와 가장 가까운 코너를 시작점(원점)으로 계산
        Vector3 baseCorner = worldCenter
                             + right * (signX * halfW)
                             - up * halfH
                             + forward * (signZ * halfD);

        Vector3 offset = Vector3.up * floorOffset;
        Vector3 pStart = baseCorner + offset;

        // 선이 뻗어나가는 방향은 시작점의 반대 방향 (부호를 반대로 적용)
        Vector3 pWidth = pStart - right * (signX * worldSize.x);
        Vector3 pDepth = pStart - forward * (signZ * worldSize.z);
        Vector3 pHeight = pDepth + up * worldSize.y;

        // ── LineRenderer ──
        if (guideLine != null)
        {
            guideLine.useWorldSpace = true;
            guideLine.positionCount = 4;
            guideLine.SetPositions(new Vector3[] { pWidth, pStart, pDepth, pHeight });
        }

        // ── 텍스트 라벨 ──
        // 텍스트를 바깥쪽으로 밀어내는 방향도 카메라 위치에 맞춰 동적으로 회전
        Vector3 widthOffsetDir = forward * (signZ * textOffset);
        Vector3 depthOffsetDir = right * (signX * textOffset);
        Vector3 heightOffsetDir = right * (signX * textOffset);

        UpdateLabel(widthText, pStart, pWidth, $"W: {worldSize.x * 100:F0}cm", widthOffsetDir);
        UpdateLabel(depthText, pStart, pDepth, $"D: {worldSize.z * 100:F0}cm", depthOffsetDir);
        UpdateLabel(heightText, pDepth, pHeight, $"H: {worldSize.y * 100:F0}cm", heightOffsetDir);
    }

    private void UpdateLabel(TextMeshProUGUI label, Vector3 start, Vector3 end, string text, Vector3 offsetDir)
    {
        if (label == null) return;

        label.transform.position = (start + end) * 0.5f + offsetDir;
        label.text = text;

        if (mainCamera != null)
        {
            label.transform.LookAt(
                label.transform.position + mainCamera.transform.rotation * Vector3.forward,
                mainCamera.transform.rotation * Vector3.up
            );
        }
    }

    private Bounds GetCombinedWorldBounds(GameObject obj)
    {
        Renderer[] renderers = obj.GetComponentsInChildren<Renderer>();
        Bounds bounds = new Bounds();
        bool hasBounds = false;

        foreach (Renderer r in renderers)
        {
            if (r.transform.IsChildOf(this.transform)) continue;
            if (!hasBounds) { bounds = r.bounds; hasBounds = true; }
            else { bounds.Encapsulate(r.bounds); }
        }

        return hasBounds ? bounds : new Bounds(obj.transform.position, Vector3.zero);
    }
}