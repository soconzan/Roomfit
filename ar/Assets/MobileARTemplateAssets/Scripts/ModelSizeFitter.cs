using UnityEngine;

public class ModelSizeFitter : MonoBehaviour
{
    [Header("🎯 목표 사이즈 (단위: cm)")]
    public float targetWidthCm = 100f;  
    public float targetHeightCm = 100f; 
    public float targetDepthCm = 100f;  

    [Header("⚙️ 시작 시 자동 적용")]
    public bool applyOnStart = true;

    [Header("🛠️ 테스트 조작판")]
    public bool applySizeNow = false;

    // [추가됨] AR 스크립트가 스케일을 바꾸지 못하도록 잠그는 변수
    private Vector3 lockedScale;
    private bool isScaleLocked = false;

    void Start()
    {
        if (applyOnStart) ApplyTargetSize();
    }

    private void OnValidate()
    {
        if (applySizeNow)
        {
            ApplyTargetSize();
            applySizeNow = false; 
        }
    }

    public void ApplyTargetSize(float widthCm, float heightCm, float depthCm)
    {
        targetWidthCm = widthCm;
        targetHeightCm = heightCm;
        targetDepthCm = depthCm;
        ApplyTargetSize(); 
    }

    public void ApplyTargetSize()
    {
        Quaternion originalRot = transform.rotation;
        transform.rotation = Quaternion.identity;

        Bounds currentBounds = GetModelBounds();

        if (currentBounds.size == Vector3.zero)
        {
            transform.rotation = originalRot;
            return;
        }

        float targetW = targetWidthCm / 100f;
        float targetH = targetHeightCm / 100f;
        float targetD = targetDepthCm / 100f;

        float scaleRatioX = targetW / currentBounds.size.x;
        float scaleRatioY = targetH / currentBounds.size.y;
        float scaleRatioZ = targetD / currentBounds.size.z;

        // 1. 스케일 적용
        transform.localScale = new Vector3(
            transform.localScale.x * scaleRatioX,
            transform.localScale.y * scaleRatioY,
            transform.localScale.z * scaleRatioZ
        );

        // 2. [추가됨] 적용된 스케일을 기억하고 잠금 모드 켜기!
        lockedScale = transform.localScale;
        isScaleLocked = true;

        transform.rotation = originalRot;

        ModelSizeGuide guide = GetComponentInChildren<ModelSizeGuide>();
        if (guide != null) guide.RecalculateSize();
    }

    // [추가됨] AR 스크립트가 Update에서 스케일을 망쳐놓으면, LateUpdate에서 즉시 원상복구!
    void LateUpdate()
    {
        if (isScaleLocked && transform.localScale != lockedScale)
        {
            transform.localScale = lockedScale;
        }
    }

    private Bounds GetModelBounds()
    {
        Renderer[] renderers = GetComponentsInChildren<Renderer>();
        Bounds bounds = new Bounds();
        bool hasBounds = false;

        foreach (Renderer r in renderers)
        {
            if (r.GetComponentInParent<ModelSizeGuide>() != null) continue;

            if (!hasBounds) { bounds = r.bounds; hasBounds = true; }
            else { bounds.Encapsulate(r.bounds); }
        }

        return hasBounds ? bounds : new Bounds(transform.position, Vector3.zero);
    }
}