using UnityEngine;
using TMPro; // TextMeshPro를 사용하기 위한 네임스페이스
using UnityEngine.UI; // Image, RawImage 등을 사용하기 위한 네임스페이스
using UnityEngine.Networking; // 웹 통신을 위해 반드시 추가해야 합니다!
using System.Collections;       // 코루틴(IEnumerator)을 사용하기 위해 추가합니다!

public class ProductItemUI : MonoBehaviour
{
    // Inspector에서 연결해 줄 UI 요소들
    public TextMeshProUGUI nameText;
    public TextMeshProUGUI priceText;
    public RawImage thumbnailImage; // 웹에서 다운받은 이미지는 주로 RawImage를 씁니다.

    // 데이터를 받아서 UI에 적용하는 함수
    public void SetupCard(ProductARData data)
    {
        nameText.text = data.productName;
        // 가격에 콤마(,)를 찍고 '원'을 붙여줍니다.
        priceText.text = data.productPrice.ToString("N0") + "원"; 

        // URL이 비어있지 않다면 이미지 다운로드 시작!
        if (!string.IsNullOrEmpty(data.imageUrl))
        {
            StartCoroutine(DownloadImage(data.imageUrl)); 
        }
    }
    
    public void SetupCard(RecommendItem item)
    {
        nameText.text = item.productName;
        priceText.text = item.productPrice.ToString("N0") + "원";

        if (!string.IsNullOrEmpty(item.imageUrl))
            StartCoroutine(DownloadImage(item.imageUrl));
    }

    // 웹에서 이미지를 비동기로 다운로드하는 함수
    private IEnumerator DownloadImage(string url)
    {
        // 1. 해당 URL로 이미지(Texture) 요청을 보냅니다.
        using (UnityWebRequest request = UnityWebRequestTexture.GetTexture(url))
        {
            // SSL 인증서 검증 우회 (서버 인증서가 IP와 불일치하는 경우 대응)
            request.certificateHandler = new AcceptAllCertificates();
            yield return request.SendWebRequest();

            // 3. 에러가 났는지 확인합니다.
            if (request.result == UnityWebRequest.Result.ConnectionError || request.result == UnityWebRequest.Result.ProtocolError)
            {
                Debug.LogError("이미지 다운로드 실패: " + request.error);
            }
            else
            {
                // 4. 성공했다면 다운받은 이미지를 RawImage에 쏙 넣습니다!
                Texture2D downloadedTexture = DownloadHandlerTexture.GetContent(request);
                thumbnailImage.texture = downloadedTexture;
            }
        }
    }
}