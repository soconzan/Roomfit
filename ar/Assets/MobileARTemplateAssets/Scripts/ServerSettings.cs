// ServerSettings.cs
using UnityEngine;

[CreateAssetMenu(fileName = "ServerSettings", menuName = "Config/Server Settings")]
public class ServerSettings : ScriptableObject
{
    [Header("Server Configuration")]
    public string baseUrl = "http://158.179.167.248:8080";
    public string productApiEndpoint = "/api/products/ar";

    public string GetProductUrl() => baseUrl + productApiEndpoint;

    // Ä¸ÃÄ + ruler
    public string recommendApiEndpoint = "/api/recommend";
    public string GetRecommendUrl() => baseUrl + recommendApiEndpoint;
}