using System.Collections.Generic;
using UnityEngine;
using UnityEngine.XR.ARFoundation;
using UnityEngine.XR.ARSubsystems;
using UnityEngine.InputSystem;
using TMPro;

public class RulerManager : MonoBehaviour
{
    public ARRaycastManager raycastManager;
    public LineRenderer lineRenderer;
    public LineRenderer lineRendererHeight;
    public GameObject worldCanvas;
    public TextMeshProUGUI distanceText;

    [Header("--- 박스 미리보기 ---")]
    public GameObject boxPreview;

    [Header("--- 측정 결과 패널 ---")]
    public GameObject resultPanel;
    public TextMeshProUGUI resultWidthText;
    public TextMeshProUGUI resultDepthText;
    public TextMeshProUGUI resultHeightText;

    [Header("--- 수정 입력 ---")]
    public GameObject editPanel;
    public TMP_InputField inputWidth;
    public TMP_InputField inputDepth;
    public TMP_InputField inputHeight;

    [Header("--- 안내 패널 ---")]
    public GameObject disclaimerPanel;

    [Header("--- Top Panel 텍스트 ---")]
    public GameObject topPanel;
    [SerializeField] private TextMeshProUGUI topStepText;
    [SerializeField] private TextMeshProUGUI topTitleText;
    [SerializeField] private TextMeshProUGUI topDescText;

    [SerializeField] private GameObject loadingPanel;

    [SerializeField] private GameObject uiChangePanel;

    private static readonly string[] instructions = new string[]
    {
        "시작점을 터치하세요",
        "가로 길이를 측정합니다\n끝점을 터치하세요",
        "세로 길이를 측정합니다\n끝점을 터치하세요",
        "높이를 측정합니다\n끝점을 터치하세요",
        "측정이 완료되었습니다."
    };

    private Vector3 startPos, widthPos, depthPos, heightPos;
    private int currentStep = 0;
    private Vector3 currentHitPos;
    private bool hasHit = false;
    private bool disclaimerConfirmed = false;


    void Start()
    {
        // group_ruler가 비활성화될 때 같이 꺼지지 않도록 씬 루트로 분리
        lineRenderer.transform.SetParent(null, true);
        if (lineRendererHeight != null) lineRendererHeight.transform.SetParent(null, true);
        if (worldCanvas != null) worldCanvas.transform.SetParent(null, true);

        lineRenderer.material.SetInt("_ZTest", (int)UnityEngine.Rendering.CompareFunction.Always);
        lineRenderer.material.renderQueue = 4500;
        if (lineRendererHeight != null)
        {
            lineRendererHeight.material.SetInt("_ZTest", (int)UnityEngine.Rendering.CompareFunction.Always);
            lineRendererHeight.material.renderQueue = 4500;
        }

        lineRenderer.positionCount = 0;
        if (lineRendererHeight != null) lineRendererHeight.positionCount = 0;
        if (boxPreview != null) boxPreview.SetActive(false);
        worldCanvas.SetActive(false);
        if (resultPanel != null) resultPanel.SetActive(false);
        Debug.Log("loadingPanel" + loadingPanel);
        if(loadingPanel != null) loadingPanel.SetActive(false);
        UpdateInstruction();
    }

    void Update()
    {
        if (!disclaimerConfirmed) return;
        if (raycastManager == null || lineRenderer == null || worldCanvas == null || distanceText == null) return;

        if (currentStep < 3)
        {
            Vector2 screenCenter = new Vector2(Screen.width * 0.5f, Screen.height * 0.5f);
            List<ARRaycastHit> hits = new List<ARRaycastHit>();
            if (raycastManager.Raycast(screenCenter, hits, TrackableType.PlaneWithinPolygon)
                || raycastManager.Raycast(screenCenter, hits, TrackableType.FeaturePoint))
            {
                currentHitPos = hits[0].pose.position;
                hasHit = true;
            }
        }

        if (hasHit || currentStep == 3)
            UpdateGuideline();

        if (Touchscreen.current == null || !Touchscreen.current.primaryTouch.press.wasPressedThisFrame) return;

        if (currentStep == 3)
        {
            NextStep();
        }
        else
        {
            Vector2 touchPos = Touchscreen.current.primaryTouch.position.ReadValue();
            List<ARRaycastHit> tapHits = new List<ARRaycastHit>();
            if (raycastManager.Raycast(touchPos, tapHits, TrackableType.PlaneWithinPolygon)
                || raycastManager.Raycast(touchPos, tapHits, TrackableType.FeaturePoint))
            {
                currentHitPos = tapHits[0].pose.position;
                hasHit = true;
                NextStep();
            }
        }
    }

    void UpdateGuideline()
    {
        if (currentStep == 0 || currentStep >= 4) return;

        Vector3 liveEnd = GetLiveEndpoint();
        Vector3 segStart = GetSegmentStart();

        switch (currentStep)
        {
            case 1:
                lineRenderer.SetPosition(1, liveEnd);
                break;

            case 2:
                // 직사각형 실시간 미리보기
                Vector3 p4 = startPos + (liveEnd - widthPos);
                lineRenderer.positionCount = 5;
                lineRenderer.SetPosition(0, startPos);
                lineRenderer.SetPosition(1, widthPos);
                lineRenderer.SetPosition(2, liveEnd);
                lineRenderer.SetPosition(3, p4);
                lineRenderer.SetPosition(4, startPos);
                break;

            case 3:
                if (lineRendererHeight != null)
                    lineRendererHeight.SetPosition(1, liveEnd);
                UpdateBoxPreview(liveEnd);
                break;
        }

        float dist = Vector3.Distance(segStart, liveEnd);
        distanceText.text = (dist * 100f).ToString("F1") + " cm";
        worldCanvas.SetActive(true);
        worldCanvas.transform.position = (segStart + liveEnd) / 2f + Vector3.up * 0.05f;
        worldCanvas.transform.LookAt(Camera.main.transform);
        worldCanvas.transform.Rotate(0, 180, 0);
    }

    Vector3 GetLiveEndpoint()
    {
        switch (currentStep)
        {
            case 1:
                return new Vector3(currentHitPos.x, startPos.y, currentHitPos.z);
            case 2:
                if ((widthPos - startPos).sqrMagnitude < 0.0001f) return currentHitPos;
                return ProjectPos(widthPos, currentHitPos, (widthPos - startPos).normalized);
            case 3:
                return GetHeightEndpoint();
            default:
                return currentHitPos;
        }
    }

    Vector3 GetSegmentStart()
    {
        switch (currentStep)
        {
            case 1: return startPos;
            case 2: return widthPos;
            case 3: return depthPos;
            default: return startPos;
        }
    }

    void NextStep()
    {
        switch (currentStep)
        {
            case 0:
                startPos = currentHitPos;
                lineRenderer.positionCount = 2;
                lineRenderer.SetPosition(0, startPos);
                lineRenderer.SetPosition(1, startPos);
                break;

            case 1:
                widthPos = GetLiveEndpoint();
                lineRenderer.SetPosition(1, widthPos);
                break;

            case 2:
                depthPos = GetLiveEndpoint();
                Vector3 p4 = startPos + (depthPos - widthPos);
                lineRenderer.positionCount = 5;
                lineRenderer.SetPosition(0, startPos);
                lineRenderer.SetPosition(1, widthPos);
                lineRenderer.SetPosition(2, depthPos);
                lineRenderer.SetPosition(3, p4);
                lineRenderer.SetPosition(4, startPos);
                // 높이 선 초기화
                if (lineRendererHeight != null)
                {
                    lineRendererHeight.positionCount = 2;
                    lineRendererHeight.SetPosition(0, depthPos);
                    lineRendererHeight.SetPosition(1, depthPos);
                }
                break;

            case 3:
                heightPos = GetLiveEndpoint();
                if (lineRendererHeight != null)
                    lineRendererHeight.SetPosition(1, heightPos);
                ShowResult();
                break;
        }

        if (currentStep < 4)
            currentStep++;

        UpdateInstruction();
    }

    void ShowResult()
    {
        Debug.Log("[RulerManager] ShowResult called. step=" + currentStep);
        float width  = Vector3.Distance(startPos, widthPos)  * 100f;
        float depth  = Vector3.Distance(widthPos, depthPos)  * 100f;
        float height = Vector3.Distance(depthPos, heightPos) * 100f;

        if (resultWidthText  != null) resultWidthText.text  = $"가로: {width:F1} cm";
        if (resultDepthText  != null) resultDepthText.text  = $"세로: {depth:F1} cm";
        if (resultHeightText != null) resultHeightText.text = $"높이: {height:F1} cm";

        if (editPanel != null) editPanel.SetActive(false);
        if (resultPanel != null) resultPanel.SetActive(true);
        worldCanvas.SetActive(false);

        FindAnyObjectByType<RecommendManager>()?.OnMeasured(width, depth, height);
        Debug.Log("OnMeasured 호출됨: " + width + ", " + depth + ", " + height);
    }

    public void OnConfirmResult()
    {
        Debug.Log("[RulerManager] OnConfirmResult called");
        var rm = FindAnyObjectByType<RecommendManager>();
        if (rm == null) { Debug.LogError("[RulerManager] RecommendManager not found!"); return; }

        if (!rm.isCaptured)
        {
            Debug.LogWarning("캡처를 먼저 해주세요.");
            return;
        }

        if (resultPanel != null) resultPanel.SetActive(false);
        if (topPanel != null) topPanel.SetActive(false);
        //rm.ShowRecommendationPanel();
        rm.ShowLoadingPanel();
        Debug.Log("[RulerManager] Calling SendRecommendRequest");
        rm.SendRecommendRequest();
    }

    public void OnEditResult()
    {
        float width  = Vector3.Distance(startPos, widthPos)  * 100f;
        float depth  = Vector3.Distance(widthPos, depthPos)  * 100f;
        float height = Vector3.Distance(depthPos, heightPos) * 100f;

        if (inputWidth  != null) inputWidth.text  = width.ToString("F1");
        if (inputDepth  != null) inputDepth.text  = depth.ToString("F1");
        if (inputHeight != null) inputHeight.text = height.ToString("F1");

        if (resultPanel != null) resultPanel.SetActive(false);
        if (editPanel   != null) editPanel.SetActive(true);
    }

    public void OnApplyEdit()
    {
        if (float.TryParse(inputWidth.text,  out float w) &&
            float.TryParse(inputDepth.text,  out float d) &&
            float.TryParse(inputHeight.text, out float h))
        {
            if (resultWidthText  != null) resultWidthText.text  = $"가로: {w:F1} cm";
            if (resultDepthText  != null) resultDepthText.text  = $"세로: {d:F1} cm";
            if (resultHeightText != null) resultHeightText.text = $"높이: {h:F1} cm";

            FindAnyObjectByType<RecommendManager>()?.OnMeasured(w, d, h);
        }

        if (editPanel   != null) editPanel.SetActive(false);
        if (resultPanel != null) resultPanel.SetActive(true);
    }

    void UpdateBoxPreview(Vector3 heightEnd)
    {
        if (boxPreview == null) return;

        float height = heightEnd.y - depthPos.y;
        Vector3 widthVec = widthPos - startPos;
        Vector3 depthVec = depthPos - widthPos;
        float w = widthVec.magnitude;
        float d = depthVec.magnitude;

        if (height < 0.001f || w < 0.001f || d < 0.001f)
        {
            boxPreview.SetActive(false);
            return;
        }

        // 직사각형 4점 중앙 = (startPos + depthPos) / 2, y는 바닥에서 높이 절반
        Vector3 center = (startPos + depthPos) / 2f;
        center.y = depthPos.y + height * 0.5f;

        // depthVec 방향을 forward로 회전 → X축이 widthVec과 정렬됨
        Quaternion rotation = Quaternion.LookRotation(depthVec.normalized, Vector3.up);

        boxPreview.transform.position = center;
        boxPreview.transform.rotation = rotation;
        boxPreview.transform.localScale = new Vector3(w, height, d);
        boxPreview.SetActive(true);
    }

    Vector3 GetHeightEndpoint()
    {
        Ray ray = Camera.main.ScreenPointToRay(new Vector3(Screen.width * 0.5f, Screen.height * 0.5f, 0));

        Vector3 toCamera = Camera.main.transform.position - depthPos;
        toCamera.y = 0;

        if (toCamera.sqrMagnitude < 0.0001f)
            return new Vector3(depthPos.x, Camera.main.transform.position.y, depthPos.z);

        Plane verticalPlane = new Plane(toCamera.normalized, depthPos);
        if (verticalPlane.Raycast(ray, out float enter) && enter > 0f)
        {
            Vector3 hit = ray.GetPoint(enter);
            return new Vector3(depthPos.x, Mathf.Max(hit.y, depthPos.y), depthPos.z);
        }

        return new Vector3(depthPos.x, Camera.main.transform.position.y, depthPos.z);
    }

    Vector3 ProjectPos(Vector3 origin, Vector3 target, Vector3 lineDir)
    {
        Vector3 v = target - origin;
        Vector3 normal = Vector3.Cross(lineDir, Vector3.up).normalized;
        return origin + Vector3.Project(v, normal);
    }

    void UpdateInstruction()
    {
        if (currentStep < instructions.Length)
            if (topDescText != null) topDescText.text = instructions[currentStep];
    }

    public void OnDisclaimerConfirmed()
    {
        disclaimerConfirmed = true;
        if (disclaimerPanel != null) disclaimerPanel.SetActive(false);
        UpdateInstruction();
    }

    public void ClearVisuals()
    {
        lineRenderer.positionCount = 0;
        if (lineRendererHeight != null) lineRendererHeight.positionCount = 0;
        if (boxPreview != null) boxPreview.SetActive(false);
        worldCanvas.SetActive(false);
    }

    public void ResetMeasurement()
    {
        disclaimerConfirmed = false;
        currentStep = 0;
        hasHit = false;
        lineRenderer.positionCount = 0;
        if (lineRendererHeight != null) lineRendererHeight.positionCount = 0;
        if (boxPreview != null) boxPreview.SetActive(false);
        worldCanvas.SetActive(false);
        if (resultPanel != null) resultPanel.SetActive(false);
        if (loadingPanel != null) loadingPanel.SetActive(false);
        if (uiChangePanel != null) uiChangePanel.SetActive(false);
        if (disclaimerPanel != null) disclaimerPanel.SetActive(true);
    }
}
