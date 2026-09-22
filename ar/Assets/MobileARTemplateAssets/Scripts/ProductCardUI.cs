using UnityEngine;
using TMPro; // TextMeshPro를 사용하기 위한 네임스페이스
using UnityEngine.UI; // Image, RawImage 등을 사용하기 위한 네임스페이스
using UnityEngine.Networking; // 웹 통신을 위해 반드시 추가해야 합니다!
using System.Collections;       // 코루틴(IEnumerator)을 사용하기 위해 추가합니다!

public class ProductCardUI : MonoBehaviour
{
    // Inspector에서 연결해 줄 UI 요소들
    public TextMeshProUGUI nameText;
    public TextMeshProUGUI priceText;
    //public Image bookmarkIcon; 
    public RawImage thumbnailImage; // 웹에서 다운받은 이미지는 주로 RawImage를 씁니다.

    public Button selectButton;
    private string currentModelUrl;
    private long currentProductId;
    private string currentProductName;
    private int currentPrice;
    private string currentImageUrl;
    private float currentWidth;
    private float currentHeight;
    private float currentDepth;

    // 데이터를 받아서 UI에 적용하는 함수
    public void SetupCard(ProductData data)
    {
        nameText.text = data.productName;
        priceText.text = data.price.ToString("N0") + "원";
        currentProductId = data.productId;
        currentProductName = data.productName;
        currentPrice = data.price;
        currentImageUrl = data.imageUrl;
        currentModelUrl = data.modelUrl;
        currentWidth = data.width;
        currentHeight = data.height;
        currentDepth = data.depth;

        // 즐겨찾기 상태에 따라 아이콘 색상 변경 (예시)
        //bookmarkIcon.color = data.isBookmarked ? Color.yellow : Color.gray;

        if (Application.isPlaying && selectButton != null)
        {
            selectButton.onClick.AddListener(OnCardClicked);
        }

        // URL이 비어있지 않다면 이미지 다운로드 시작!
        if (Application.isPlaying && !string.IsNullOrEmpty(data.imageUrl))
        {
            StartCoroutine(DownloadImage(data.imageUrl)); 
        }
    }
    private void OnCardClicked()
    {
        Debug.Log($"[ProductCardUI] {nameText.text} 클릭됨");

        // 상세 페이지로 productId, imageUrl 넘기기
        var detailView = FindAnyObjectByType<DetailViewUI>(FindObjectsInactive.Include);
        if (detailView != null)
            detailView.Setup(currentProductId, thumbnailImage.texture);
        else
            Debug.LogWarning("[ProductCardUI] DetailViewUI not found");

        if (string.IsNullOrEmpty(currentModelUrl)) return;

        // 1. 공용 게시판에 장전 (기존과 동일)
        GLBModelLoader.pendingModelUrl = currentModelUrl;
        // ★ 추가: 사이즈 정보도 공용 장전소에 같이 장전!
        GLBModelLoader.pendingWidth = currentWidth;
        GLBModelLoader.pendingHeight = currentHeight;
        GLBModelLoader.pendingDepth = currentDepth;
        
        // ★ 2. 새로 추가: 씬에 이미 소환된 가구(로더)가 있는지 찾아봅니다.
        var existingLoader = FindAnyObjectByType<GLBModelLoader>();
        
        if (existingLoader != null)
        {
            // 이미 바닥에 소환되어 있다면, 이전 모델을 부수고 즉시 새 모델을 입힙니다!
            // (GLBModelLoader 안에 ClearCurrentModel()이 있어서 기존 모델은 알아서 싹 지워집니다)
            existingLoader.LoadModelFromUrl(currentModelUrl);
            Debug.Log($"[ProductCardUI] 🔄 replace existing model: {currentModelUrl}");
        }
        else
        {
            // 아직 바닥에 아무것도 소환하지 않은 상태라면 장전만 해둡니다.
            Debug.Log($"[ProductCardUI] 🔫 model readied: {currentModelUrl}");
        }
    }
    
    // 웹에서 이미지를 비동기로 다운로드하는 함수
    private IEnumerator DownloadImage(string url)
    {
        // 1. 해당 URL로 이미지(Texture) 요청을 보냅니다.
        using (UnityWebRequest request = UnityWebRequestTexture.GetTexture(url))
        {
            // SSL 인증서 검증 우회 (서버 인증서가 IP와 불일치하는 경우 대응)
            request.certificateHandler = new AcceptAllCertificates();
            Debug.Log($"[ImageURL] {nameText.text} image downloading");
            yield return request.SendWebRequest();

            // 3. 에러가 났는지 확인합니다.
            if (request.result == UnityWebRequest.Result.ConnectionError || request.result == UnityWebRequest.Result.ProtocolError)
            {
                Debug.LogError("image download failed : " + request.error);
            }
            else
            {
                Debug.Log($"[ImageURL] {nameText.text} download success");
                // 4. 성공했다면 다운받은 이미지를 RawImage에 쏙 넣습니다!
                Texture2D downloadedTexture = DownloadHandlerTexture.GetContent(request);
                thumbnailImage.texture = downloadedTexture;
            }
        }
    }
}
