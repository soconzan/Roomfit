using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Networking;
using UnityEngine.UI;
using Newtonsoft.Json;

class AcceptAllCertificates : UnityEngine.Networking.CertificateHandler
{
    protected override bool ValidateCertificate(byte[] certificateData) => true;
}

public class RecommendManager : MonoBehaviour
{
    [SerializeField] public ServerSettings serverSettings;
    [SerializeField] private Button sendButton;
    [SerializeField] private GameObject recommendationPanel;
    [SerializeField] private GameObject loadingPanel;
    [SerializeField] private ProductManager productManager;
    [SerializeField] private ARModeController arModeController;

    private CanvasGroup recommendationCanvasGroup;

    private byte[] capturedJpg;
    private float measuredWidth;
    private float measuredDepth;
    private float measuredHeight;
    private int? categoryId = null;

    public bool isCaptured = false;
    private bool isMeasured = false;

    private void Start()
    {
        recommendationCanvasGroup = recommendationPanel.GetComponent<CanvasGroup>();
        if (recommendationCanvasGroup == null)
            recommendationCanvasGroup = recommendationPanel.AddComponent<CanvasGroup>();

        SetRecommendationPanelVisible(false);
        if (loadingPanel != null) loadingPanel.SetActive(false);
sendButton.interactable = false;
    }

    private void SetRecommendationPanelVisible(bool visible)
    {
        if (recommendationCanvasGroup == null) return;
        recommendationCanvasGroup.alpha = visible ? 1f : 0f;
        recommendationCanvasGroup.interactable = visible;
        recommendationCanvasGroup.blocksRaycasts = visible;
    }

    public void OnCaptured(byte[] jpg)
    {
        capturedJpg = jpg;
        isCaptured = true;
        CheckReady();
    }

    public void OnMeasured(float width, float depth, float height)
    {
        measuredWidth = width;
        measuredDepth = depth;
        measuredHeight = height;
        isMeasured = true;
        CheckReady();
    }

    private void CheckReady()
    {
        sendButton.interactable = isCaptured && isMeasured;
    }

    public void SetCategoryId(int? id)
    {
        categoryId = id;
    }

    public void ShowLoadingPanel()
    {
        if (loadingPanel != null) loadingPanel.SetActive(true);
    }

    public void SendRecommendRequest()
    {
        Debug.Log("[RecommendManager] SendRecommendRequest called");
        StartCoroutine(PostRecommend());
    }

    private IEnumerator PostRecommend()
    {
        sendButton.interactable = false;

        WWWForm form = new WWWForm();
        if (capturedJpg != null)
            form.AddBinaryData("image", capturedJpg, "room.jpg", "image/jpeg");
        form.AddField("width", (measuredWidth * 10f).ToString("F1"));
        form.AddField("depth", (measuredDepth * 10f).ToString("F1"));
        form.AddField("height", (measuredHeight * 10f).ToString("F1"));
        Debug.Log("categoryId: " + (categoryId.HasValue ? categoryId.Value.ToString() : "null"));
        if (categoryId.HasValue)
            form.AddField("category", categoryId.Value.ToString());

        using var request = UnityWebRequest.Post(serverSettings.GetRecommendUrl(), form);
        request.certificateHandler = new AcceptAllCertificates();
        request.timeout = 300;
        yield return request.SendWebRequest();

        if (loadingPanel != null) loadingPanel.SetActive(false);

        if (request.result == UnityWebRequest.Result.Success)
        {
            string json = System.Text.Encoding.UTF8.GetString(request.downloadHandler.data);
            Debug.Log("recommend success: " + json);

            var response = JsonConvert.DeserializeObject<RecommendApiResponse>(json);
            if (response != null && response.success && response.data != null && response.data.Count > 0)
            {
                if (arModeController != null) arModeController.SetPlacementMode();
                SetRecommendationPanelVisible(true);

                if (productManager != null)
                    productManager.DisplayRecommendProducts(response.data);
                else
                    Debug.LogError("[RecommendManager] ProductManager not found!");
            }
            else
            {
                Debug.LogWarning("recommend response empty or failed");
            }
        }
        else
        {
            Debug.LogWarning("recommend fail: " + request.error + " / status: " + request.responseCode);
            sendButton.interactable = true;
        }
    }
}
