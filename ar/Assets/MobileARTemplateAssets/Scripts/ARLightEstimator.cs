using UnityEngine;
using UnityEngine.XR.ARFoundation;

[RequireComponent(typeof(Light))]
public class ARLightEstimator : MonoBehaviour
{
    [Header("AR 카메라 연결")]
    public ARCameraManager cameraManager;

    [Header("💡 조명 밝기 안전장치")]
    [Tooltip("카메라가 인식한 빛의 세기에 곱해줄 보정값 (기본 0.5)")]
    [Range(0.1f, 2.0f)]
    public float intensityMultiplier = 0.5f; 

    [Tooltip("현실이 아무리 밝아도 이 수치를 넘지 않습니다. (하얗게 타는 것 방지)")]
    public float maxIntensity = 1.2f;

    [Tooltip("현실이 아무리 어두워도 이 수치 밑으로 내려가지 않습니다. (완전 까매짐 방지)")]
    public float minIntensity = 0.2f;

    private Light directionalLight;

    void Awake()
    {
        directionalLight = GetComponent<Light>();
        directionalLight.useColorTemperature = true; // ✅ 추가
    }

    void OnEnable()
    {
        if (cameraManager != null) cameraManager.frameReceived += OnCameraFrameReceived;
    }

    void OnDisable()
    {
        if (cameraManager != null) cameraManager.frameReceived -= OnCameraFrameReceived;
    }

    private void OnCameraFrameReceived(ARCameraFrameEventArgs args)
    {
        // 1. 밝기(Intensity) 적용 및 제한
        if (args.lightEstimation.averageBrightness.HasValue)
        {
            // 카메라가 인식한 원본 밝기에 보정값을 곱함
            float estimatedIntensity = args.lightEstimation.averageBrightness.Value * intensityMultiplier;
            
            // 너무 하얗게 타거나 까매지는 것을 막기 위해 min ~ max 사이로 값을 가둠
            directionalLight.intensity = Mathf.Clamp(estimatedIntensity, minIntensity, maxIntensity);
        }

        // 2. 색 온도와 mainLightColor는 둘 중 하나만 사용
        // mainLightColor가 있으면 우선 사용, 없으면 색 온도로 fallback
        if (args.lightEstimation.mainLightColor.HasValue)
        {
            directionalLight.useColorTemperature = false; // ✅ color 직접 지정 시 비활성화
            directionalLight.color = args.lightEstimation.mainLightColor.Value;
        }
        else if (args.lightEstimation.averageColorTemperature.HasValue)
        {
            directionalLight.useColorTemperature = true; // ✅ 색온도 사용 시 활성화
            directionalLight.colorTemperature = args.lightEstimation.averageColorTemperature.Value;
        }

        // 3. 빛의 방향(그림자 방향) 적용
        if (args.lightEstimation.mainLightDirection.HasValue)
        {
            directionalLight.transform.rotation = Quaternion.LookRotation(args.lightEstimation.mainLightDirection.Value);
        }
    }
}