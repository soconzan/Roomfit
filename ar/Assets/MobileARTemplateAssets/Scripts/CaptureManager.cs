using UnityEngine.XR.ARSubsystems;
using UnityEngine;
using UnityEngine.XR.ARFoundation;
using Unity.Collections;
using UnityEngine.UI;
using TMPro;

public class CaptureManager : MonoBehaviour
{
    [SerializeField] private ARCameraManager arCameraManager;
    [SerializeField] private RecommendManager recommendManager;

    [Header("--- Top Panel 텍스트 ---")]
    [SerializeField] private TextMeshProUGUI stepText;
    [SerializeField] private TextMeshProUGUI titleText;
    [SerializeField] private TextMeshProUGUI descText;

    void Start()
    {
        if (stepText  != null) stepText.text  = "STEP 1";
        if (titleText != null) titleText.text = "방 사진 촬영";
        if (descText  != null) descText.text  = "고객님의 방 사진을 촬영합니다\n잘 보이게 찍어주세요";
    }

    public void StartCapture()
    {
        CaptureFrame();
    }

private void CaptureFrame()
{
    if (!arCameraManager.TryAcquireLatestCpuImage(out XRCpuImage image))
    {
        Debug.LogWarning("Failed to acquire camera image.");
        return;
    }

    int outW = Mathf.Min(image.width, 640);
    int outH = Mathf.RoundToInt(image.height * (outW / (float)image.width));

    var conversionParams = new XRCpuImage.ConversionParams
    {
        inputRect = new RectInt(0, 0, image.width, image.height),
        outputDimensions = new Vector2Int(outW, outH),
        outputFormat = TextureFormat.RGBA32,
        transformation = XRCpuImage.Transformation.MirrorY
    };

    var texture = new Texture2D(outW, outH, TextureFormat.RGBA32, false);
    var rawBuffer = new NativeArray<byte>(image.GetConvertedDataSize(conversionParams), Allocator.Temp);

    image.Convert(conversionParams, rawBuffer);
    texture.LoadRawTextureData(rawBuffer);
    texture.Apply();

    rawBuffer.Dispose();
    image.Dispose();

    byte[] jpg = texture.EncodeToJPG(75);
    Destroy(texture);

    Debug.Log("Capture complete. JPG size: " + jpg.Length);

    if (stepText  != null) stepText.text  = "STEP 2";
    if (titleText != null) titleText.text = "공간 측정";
    if (descText  != null) descText.text  = "가로 · 세로 · 높이 순서로 터치해 측정하세요";

    recommendManager.OnCaptured(jpg);
    }
}