using UnityEngine;
using UnityEngine.UI;
using UnityEngine.EventSystems;

public class DetailViewUI : MonoBehaviour, IPointerClickHandler
{
    public RawImage thumbnailImage;

    private long currentProductId;

    public void Setup(long productId, Texture texture)
    {
        currentProductId = productId;
        if (thumbnailImage != null && texture != null) thumbnailImage.texture = texture;
        gameObject.SetActive(true);
    }

    public void OnPointerClick(PointerEventData eventData)
    {
        Application.OpenURL($"roomfit-client:///products/{currentProductId}");
    }
}
