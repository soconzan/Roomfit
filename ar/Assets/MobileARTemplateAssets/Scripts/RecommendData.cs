using System.Collections.Generic;

[System.Serializable]
public class RecommendItem
{
    public long productId;
    public string productName;
    public long productPrice;
    public string imageUrl;
    public string modelUrl;
    public float productWidth;
    public float productDepth;
    public float productHeight;
}

[System.Serializable]
public class RecommendApiResponse
{
    public bool success;
    public string message;
    public List<RecommendItem> data;
}
