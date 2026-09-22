using UnityEngine;
using UnityEngine.InputSystem;
using System;

//public class DeepLinkManager : MonoBehaviour
//{
//    // ScriptableObject를 연결
//    public ServerSettings ServerSettings;

//    void Awake()
//    {
//        // 딥링크 이벤트 연결
//        Application.deepLinkActivated += OnDeepLinkActivated;
//        Debug.Log("현재 서버 주소: " + ServerSettings.baseUrl);

//        // 앱이 처음 켜질 때 들어온 딥링크 확인
//        if (!string.IsNullOrEmpty(Application.absoluteURL))
//        {
//            OnDeepLinkActivated(Application.absoluteURL);
//        }
//    }

//    private void OnDeepLinkActivated(string url)
//    {

//        Debug.Log("[DeepLink] 수신된 URL: " + url);

//        // URL을 파싱해서 id=123 이나 env=dev 등을 추출
//        // 예: 만약 URL에 env=prod 가 있다면 CurrentSettings = prodSettings; 로 교체
//        // 예: URL에서 추출한 상품 ID(123)로 3D 모델 다운로드 시작
//    }
//}

public class DeepLinkManager : MonoBehaviour
{
    [SerializeField] private GameObject uiRecommend;
    [SerializeField] private RecommendManager recommendManager;
    [SerializeField] private ARModeController modeController;

    private static bool isFirstLoad = true;

    void Awake()
    {
        Application.deepLinkActivated += OnDeepLinkActivated;

        if (!string.IsNullOrEmpty(Application.absoluteURL))
        {
            OnDeepLinkActivated(Application.absoluteURL);
        }
        else
        {
            Debug.Log("[DeepLink] No Deeplink");
        }

        isFirstLoad = false;
    }

    void Update()
    {
        if (Keyboard.current != null && Keyboard.current[Key.Escape].wasPressedThisFrame)
            Application.Quit();
    }

    void OnDestroy()
    {
        Application.deepLinkActivated -= OnDeepLinkActivated;
    }

    private void OnDeepLinkActivated(string url)
    {
        Debug.Log("[DeepLink] 수신된 URL: " + url);

        if (!isFirstLoad)
        {
            Debug.Log("[DeepLink] 앱 재시작");
#if UNITY_ANDROID
            using var unityPlayer = new AndroidJavaClass("com.unity3d.player.UnityPlayer");
            using var activity = unityPlayer.GetStatic<AndroidJavaObject>("currentActivity");
            using var uri = new AndroidJavaClass("android.net.Uri").CallStatic<AndroidJavaObject>("parse", url);
            using var intent = new AndroidJavaObject("android.content.Intent", "android.intent.action.VIEW", uri);
            intent.Call<AndroidJavaObject>("addFlags", 0x10000000 | 0x20000000);
            activity.Call("startActivity", intent);
            using var process = new AndroidJavaClass("android.os.Process");
            process.CallStatic("killProcess", process.CallStatic<int>("myPid"));
#endif
            return;
        }

        string mode = GetQueryParam(url, "mode");
        Debug.Log("[DeepLink] 파싱된 mode: " + (mode ?? "null"));

        if (string.IsNullOrEmpty(mode))
        {
            Debug.LogWarning("[DeepLink] mode 파라미터 없음");
            return;
        }

        switch (mode)
        {
            case "recommend":
                EnterRecommendMode(url);
                break;

            case "detail":
                EnterDetailMode(url);
                break;

            default:
                Debug.LogWarning("[DeepLink] 알 수 없는 mode: " + mode);
                break;
        }
    }

    private void EnterRecommendMode(string url)
    {
        Debug.Log("[DeepLink] Recommend 모드");

        string categoryIdStr = GetQueryParam(url, "categoryId");
        int? categoryId = int.TryParse(categoryIdStr, out int cid) ? cid : (int?)null;
        Debug.Log("[DeepLink] 파싱된 categoryId: " + (categoryId.HasValue ? categoryId.Value.ToString() : "null"));
        Debug.Log("[DeepLink] recommendManager: " + (recommendManager != null ? "연결됨" : "null"));

        if (recommendManager != null)
            recommendManager.SetCategoryId(categoryId);

        if (modeController != null)
        {
            modeController.deepLinkHandled = true;
            modeController.SetRulerMode();
        }

        if (uiRecommend != null) uiRecommend.SetActive(true);
    }

    private void EnterDetailMode(string url)
    {
        Debug.Log("[DeepLink] Detail 모드");

        string modelUrl = GetQueryParam(url, "modelUrl");
        string widthStr  = GetQueryParam(url, "width");
        string heightStr = GetQueryParam(url, "height");
        string depthStr  = GetQueryParam(url, "depth");

        Debug.Log($"[DeepLink] 파싱된 modelUrl={modelUrl ?? "null"} width={widthStr ?? "null"} height={heightStr ?? "null"} depth={depthStr ?? "null"}");

        if (!string.IsNullOrEmpty(modelUrl))
        {
            GLBModelLoader.pendingModelUrl = modelUrl;
            GLBModelLoader.pendingWidth  = float.TryParse(widthStr,  out float w) ? w / 10f : 100f;
            GLBModelLoader.pendingHeight = float.TryParse(heightStr, out float h) ? h / 10f : 100f;
            GLBModelLoader.pendingDepth  = float.TryParse(depthStr,  out float d) ? d / 10f : 100f;
            Debug.Log($"[DeepLink] 적용된 w={GLBModelLoader.pendingWidth} h={GLBModelLoader.pendingHeight} d={GLBModelLoader.pendingDepth}");
        }
        else
        {
            Debug.LogWarning("[DeepLink] modelUrl 파라미터 없음");
        }

        if (modeController != null)
        {
            modeController.deepLinkHandled = true;
            modeController.SetDetailMode();
        }

        if (uiRecommend != null) uiRecommend.SetActive(false);
    }

    private string GetQueryParam(string url, string key)
    {
        int queryStart = url.IndexOf('?');
        if (queryStart < 0) return null;

        string query = url.Substring(queryStart + 1);
        foreach (string param in query.Split('&'))
        {
            int eq = param.IndexOf('=');
            if (eq < 0) continue;

            string k = param.Substring(0, eq);
            string v = param.Substring(eq + 1);

            if (k == key)
                return Uri.UnescapeDataString(v);
        }

        return null;
    }
}