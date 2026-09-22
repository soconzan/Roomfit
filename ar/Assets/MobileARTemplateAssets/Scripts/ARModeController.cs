using System.Collections;
using UnityEngine;
using UnityEngine.XR.ARSubsystems;
using UnityEngine.XR.Interaction.Toolkit.Samples.ARStarterAssets;

public class ARModeController : MonoBehaviour
{
    [Header("--- AR 오브젝트 그룹 ---")]
    public GameObject groupPlacement;
    public GameObject groupRuler;

    [Header("--- UI 그룹 ---")]
    public GameObject uiPlacementGroup;
    public GameObject uiRulerGroup;

    [Header("--- 스폰 트리거 ---")]
    public ARInteractorSpawnTrigger spawnTrigger;

    [Header("--- 룰러 매니저 ---")]
    public RulerManager rulerManager;

    [Header("--- Detail 모드 숨김 UI ---")]
    public GameObject topPanel;
    public GameObject detailViewUI;

    [HideInInspector] public bool deepLinkHandled = false;

    void Start()
    {
        StartCoroutine(DelayedStart());
    }

    IEnumerator DelayedStart()
    {
        yield return new WaitForSeconds(1.0f);
        if (!deepLinkHandled)
            SetRulerMode();
    }

    public void SetRulerMode()
    {

        groupPlacement.SetActive(false);
        groupRuler.SetActive(true);

        uiPlacementGroup.SetActive(false);
        uiRulerGroup.SetActive(true);

        if (spawnTrigger != null) spawnTrigger.enabled = false;

        if (rulerManager != null)
        {
            rulerManager.enabled = true;
            rulerManager.ResetMeasurement();
        }

        Debug.Log("모드 전환: 줄자 측정 모드 진입");
    }

    public void SetDetailMode()
    {
        SetPlacementMode();
        if (topPanel != null) topPanel.SetActive(false);
        if (detailViewUI != null) detailViewUI.SetActive(false);
        Debug.Log("모드 전환: 상세 조회 모드 진입");
    }

    public void SetPlacementMode()
    {
        groupRuler.SetActive(false);
        groupPlacement.SetActive(true);

        uiRulerGroup.SetActive(false);
        uiPlacementGroup.SetActive(true);

        if (spawnTrigger != null) spawnTrigger.enabled = true;

        if (rulerManager != null)
        {
            rulerManager.ClearVisuals();
            rulerManager.enabled = false;
        }

        Debug.Log("모드 전환: 가구 배치 모드 진입");
    }
}
