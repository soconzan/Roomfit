using UnityEngine;
using UnityEngine.XR.ARFoundation;

public class ARSessionStarter : MonoBehaviour
{
    public ARSession arSession;

    // Flutter에서 이 함수 이름을 부를 겁니다.
    // (postMessage 규칙상 매개변수로 string을 하나 받아주는 것이 안전합니다)
    public void ResetARFromFlutter(string message)
    {
        if (arSession != null)
        {
            arSession.Reset();
            Debug.Log("[ARSessionStarter] Flutter의 호출로 AR 세션 리셋 완료!");
        }
    }
}