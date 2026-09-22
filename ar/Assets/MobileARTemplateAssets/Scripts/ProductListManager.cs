using UnityEngine;
using System.Collections.Generic;

#if UNITY_EDITOR
using UnityEditor;
#endif

public class ProductListManager : MonoBehaviour
{
    private const string PreviewPrefix = "[Preview] ";

    public GameObject productCardPrefab; // 2단계에서 만든 프리팹
    public Transform contentTransform;   // Scroll View 안의 'Content' 오브젝트
    public ServerSettings serverConfig;

    // 핵심: [SerializeField]를 붙이면 Inspector 창에 리스트가 나타납니다!
    [SerializeField]
    private List<ProductData> mockDataList;

    void Start()
    {
        // 데이터 목록을 기반으로 UI 생성하기
        GenerateList(mockDataList);
    }

    public void GenerateList(List<ProductData> dataList)
    {
        // 1. 데이터 개수만큼 반복
        foreach (ProductData data in dataList)
        {
            // 2. Content 오브젝트 아래에 프리팹 복제(생성)
            GameObject newCard = Instantiate(productCardPrefab, contentTransform);

            // 3. 생성된 카드의 ProductCardUI 스크립트를 가져와 데이터 주입
            ProductCardUI cardUI = newCard.GetComponentInChildren<ProductCardUI>();

            if (cardUI != null)
            {
                cardUI.SetupCard(new ProductData
                {
                    productName = data.productName,
                    price = (int)data.price,
                    imageUrl = data.imageUrl,
                    modelUrl = data.modelUrl, // 이 URL이 전달됨
                    width = data.width,
                    height = data.height,
                    depth = data.depth
                });
            }

        }
    }

#if UNITY_EDITOR
    [ContextMenu("Preview Mock Data In Editor")]
    public void PreviewMockDataInEditor()
    {
        if (productCardPrefab == null || contentTransform == null || mockDataList == null)
        {
            Debug.LogWarning("[ProductListManager] Preview requires Product Card Prefab, Content Transform, and Mock Data List.");
            return;
        }

        ClearPreviewItems();

        foreach (ProductData data in mockDataList)
        {
            GameObject newCard = (GameObject)PrefabUtility.InstantiatePrefab(productCardPrefab, contentTransform);
            newCard.name = PreviewPrefix + data.productName;
            Undo.RegisterCreatedObjectUndo(newCard, "Preview Product Item");

            ProductCardUI cardUI = newCard.GetComponentInChildren<ProductCardUI>();
            if (cardUI != null)
            {
                cardUI.SetupCard(data);
            }

            EditorUtility.SetDirty(newCard);
        }
    }

    [ContextMenu("Clear Preview Items")]
    public void ClearPreviewItems()
    {
        if (contentTransform == null)
        {
            return;
        }

        for (int i = contentTransform.childCount - 1; i >= 0; i--)
        {
            Transform child = contentTransform.GetChild(i);
            if (child.name.StartsWith(PreviewPrefix))
            {
                Undo.DestroyObjectImmediate(child.gameObject);
            }
        }
    }
#endif
}
