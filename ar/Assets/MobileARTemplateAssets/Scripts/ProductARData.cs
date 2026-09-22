using UnityEngine;
using System.Collections.Generic;

[System.Serializable]
public class ProductARData
{
    public long productId;
    public string productName;
    public long productPrice;
    public string imageUrl;
    public string modelUrl;
}

[System.Serializable]
public class ApiResponse
{
    public bool success;
    public string message;
    public List<ProductARData> data;
}