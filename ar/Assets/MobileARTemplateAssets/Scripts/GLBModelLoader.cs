using UnityEngine;
using GLTFast; 
using System.Threading.Tasks;

public class GLBModelLoader : MonoBehaviour
{
    // ★ 1. 추가: 게임 전체에서 공유할 '공용 장전소' 변수
    public static string pendingModelUrl = "";

    [Header("🔗 모델 설정")]
    public Transform visualsTransform; 

    [Header("⏳ 로딩 UI 설정")]
    public GameObject loadingUI; 

    [Header("🧪 테스트용 입력창")]
    public string testGlbUrl = "https://your-r2-bucket.com/model.glb";
    public bool loadTestModel = false;

    public static float pendingWidth = 100f;
    public static float pendingHeight = 100f;
    public static float pendingDepth = 100f;

    // ★ 2. 추가: AR 객체가 바닥에 소환(생성)될 때 자동으로 실행되는 함수
    private void Start()
    {
        // 생성되자마자 장전된 URL이 있는지 확인하고, 있으면 바로 다운로드 시작!
        if (!string.IsNullOrEmpty(pendingModelUrl))
        {
            LoadModelFromUrl(pendingModelUrl);
        }
    }

    private void Update()
    {
        if (loadTestModel)
        {
            loadTestModel = false; 
            if (Application.isPlaying) LoadModelFromUrl(testGlbUrl);
        }
    }

    public async void LoadModelFromUrl(string url)
    {
        if (string.IsNullOrEmpty(url)) return;

        if (loadingUI != null) loadingUI.SetActive(true);

        ClearCurrentModel();

        var gltfImport = new GltfImport();
        bool success = await gltfImport.Load(url);

        if (success)
        {
            GameObject newModel = new GameObject("Loaded_GLB_Mesh");
            newModel.transform.SetParent(visualsTransform, false);
            
            await gltfImport.InstantiateMainSceneAsync(newModel.transform);

            // 1. [새로 추가됨] 너무 금속성으로 빛나는 마테리얼을 부드러운 무광으로 보정
            MakeMaterialsMatte(newModel);

            // 2. 바닥 정렬
            AlignModelToBottom(newModel);

            // 3. WHD 사이즈 보정 및 가이드라인 갱신
            ApplyAdjustments(newModel);
        }
        else
        {
            Debug.LogError($"[GLBLoader] 모델 로드 실패! URL: {url}");
        }

        if (loadingUI != null) loadingUI.SetActive(false);
    }

    // [핵심 추가 코드] 셰이더는 놔두고, 광택/금속성 수치만 낮춥니다.
    private void MakeMaterialsMatte(GameObject model)
    {
        Renderer[] renderers = model.GetComponentsInChildren<Renderer>();
        foreach (Renderer r in renderers)
        {
            foreach (Material mat in r.materials)
            {
                // 유니티 기본(URP/Standard) 셰이더 프로퍼티 대응
                if (mat.HasProperty("_Metallic")) mat.SetFloat("_Metallic", 0.0f);
                if (mat.HasProperty("_Smoothness")) mat.SetFloat("_Smoothness", 0.2f); // 0에 가까울수록 무광
                if (mat.HasProperty("_Glossiness")) mat.SetFloat("_Glossiness", 0.2f);

                // glTFast 전용 셰이더 프로퍼티 대응
                if (mat.HasProperty("metallicFactor")) mat.SetFloat("metallicFactor", 0.0f);
                if (mat.HasProperty("roughnessFactor")) mat.SetFloat("roughnessFactor", 0.8f); // roughness(거칠기)는 높을수록 무광
            }
        }
        Debug.Log("[GLBLoader] 마테리얼 무광(Matte) 처리 완료!");
    }

    private void ClearCurrentModel()
    {
        MeshRenderer mr = visualsTransform.GetComponent<MeshRenderer>();
        if (mr != null) Destroy(mr);
        MeshFilter mf = visualsTransform.GetComponent<MeshFilter>();
        if (mf != null) Destroy(mf);

        foreach (Transform child in visualsTransform)
        {
            if (child.GetComponent<ModelSizeGuide>() != null || child.name.Contains("Guide")) continue;
            Destroy(child.gameObject);
        }
    }

    private void AlignModelToBottom(GameObject model)
    {
        Renderer[] renderers = model.GetComponentsInChildren<Renderer>();
        if (renderers.Length == 0) return;

        float minLocalY = float.MaxValue;
        foreach (Renderer r in renderers)
        {
            MeshFilter mf = r.GetComponent<MeshFilter>();
            if (mf != null && mf.sharedMesh != null)
            {
                foreach (Vector3 vertex in mf.sharedMesh.vertices)
                {
                    Vector3 worldPoint = r.transform.TransformPoint(vertex);
                    Vector3 localPoint = visualsTransform.InverseTransformPoint(worldPoint);
                    if (localPoint.y < minLocalY) minLocalY = localPoint.y;
                }
            }
        }

        if (minLocalY != float.MaxValue)
        {
            model.transform.localPosition -= new Vector3(0, minLocalY, 0);
        }
    }

    private void ApplyAdjustments(GameObject newModel)
    {
        ModelSizeFitter fitter = GetComponentInParent<ModelSizeFitter>();
        if (fitter != null) {
            fitter.ApplyTargetSize(pendingWidth, pendingHeight, pendingDepth);
        }

        ModelSizeGuide guide = GetComponentInChildren<ModelSizeGuide>();
        if (guide != null) guide.RecalculateSize();
    }
}