using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Networking;
using Newtonsoft.Json;

public class ProductManager : MonoBehaviour
{

    public Transform content;
    public GameObject itemPrefab;
    public ServerSettings serverConfig;

    void Start()
    {
        StartCoroutine(FetchProducts());
    }

    IEnumerator FetchProducts()
    {
        using var request = UnityWebRequest.Get(serverConfig.GetProductUrl());
        request.timeout = 10;
        yield return request.SendWebRequest();

        if (request.result != UnityWebRequest.Result.Success)
        {
            Debug.LogError("[ProductManager] Network error: " + request.result + " / " + request.error);
            yield break;
        }

        Debug.Log("[ProductManager] Response: " + request.downloadHandler.text);

        var response = JsonConvert.DeserializeObject<ApiResponse>(request.downloadHandler.text);

        if (response == null || response.data == null || response.data.Count == 0)
        {
            Debug.LogWarning("[ProductManager] No product data (response.data is empty)");
            yield break;
        }

        Debug.Log("[ProductManager] Loaded " + response.data.Count + " products");
        DisplayProducts(response.data);
    }

    void DisplayProducts(List<ProductARData> products)
    {
        foreach (Transform child in content)
            Destroy(child.gameObject);

        foreach (var product in products)
        {
            var item = Instantiate(itemPrefab, content);
            var cardUI = item.GetComponent<ProductCardUI>();
            if (cardUI == null)
            {
                Debug.LogError("[ProductManager] ProductCardUI component not found on itemPrefab!");
                continue;
            }
            cardUI.SetupCard(new ProductData
            {
                productName = product.productName,
                price = (int)product.productPrice,
                imageUrl = product.imageUrl,
                modelUrl = product.modelUrl
            });
        }
    }

    public void DisplayRecommendProducts(List<RecommendItem> items)
    {
        if (content == null) { Debug.LogError("[ProductManager] content is null!"); return; }
        if (itemPrefab == null) { Debug.LogError("[ProductManager] itemPrefab is null!"); return; }

        var mockList = FindAnyObjectByType<ProductListManager>(FindObjectsInactive.Include);
        if (mockList != null) mockList.gameObject.SetActive(false);

        foreach (Transform child in content)
            Destroy(child.gameObject);

        foreach (var item in items)
        {
            Debug.Log($"[ProductManager] name={item.productName} | imageUrl={item.imageUrl} | modelUrl={item.modelUrl} | width = {item.productWidth} | depth = {item.productDepth}, height = {item.productHeight}");
            var go = Instantiate(itemPrefab, content);
            var cardUI = go.GetComponentInChildren<ProductCardUI>();
            if (cardUI == null)
            {
                Debug.LogError("[ProductManager] ProductCardUI component not found on itemPrefab!");
                continue;
            }
            cardUI.SetupCard(new ProductData
            {
                productId   = item.productId,
                productName = item.productName,
                price       = (int)item.productPrice,
                imageUrl    = item.imageUrl,
                modelUrl    = item.modelUrl,
                width       = item.productWidth  / 10f,
                height      = item.productHeight / 10f,
                depth       = item.productDepth  / 10f
            });
        }
    }
}

