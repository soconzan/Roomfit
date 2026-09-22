using System;
using System.Collections.Generic;
using UnityEngine.XR.ARFoundation;
using UnityEngine.XR.Interaction.Toolkit.Samples.StarterAssets;

namespace UnityEngine.XR.Templates.AR
{
    /// <summary>
    /// Onboarding goal to be achieved as part of the <see cref="GoalManager"/>.
    /// </summary>
    public struct Goal
    {
        /// <summary>
        /// Goal state this goal represents.
        /// </summary>
        public GoalManager.OnboardingGoals CurrentGoal;

        /// <summary>
        /// This denotes whether a goal has been completed.
        /// </summary>
        public bool Completed;

        /// <summary>
        /// Creates a new Goal with the specified <see cref="GoalManager.OnboardingGoals"/>.
        /// </summary>
        /// <param name="goal">The <see cref="GoalManager.OnboardingGoals"/> state to assign to this Goal.</param>
        public Goal(GoalManager.OnboardingGoals goal)
        {
            CurrentGoal = goal;
            Completed = false;
        }
    }

    /// <summary>
    /// The GoalManager cycles through a list of Goals, each representing
    /// an <see cref="GoalManager.OnboardingGoals"/> state to be completed by the user.
    /// </summary>
    public class GoalManager : MonoBehaviour
    {
        /// <summary>
        /// State representation for the onboarding goals for the GoalManager.
        /// </summary>
        public enum OnboardingGoals
        {
            /// <summary>
            /// Current empty scene
            /// </summary>
            Empty,

            /// <summary>
            /// Find/scan for AR surfaces
            /// </summary>
            FindSurfaces,

            /// <summary>
            /// Tap a surface to spawn an object
            /// </summary>
            TapSurface,

            /// <summary>
            /// Show movement hints
            /// </summary>
            Hints,

            /// <summary>
            /// Show scale and rotate hints
            /// </summary>
            Scale
        }

        /// <summary>
        /// Individual step instructions to show as part of a goal.
        /// </summary>
        [Serializable]
        public class Step
        {
            /// <summary>
            /// The GameObject to enable and show the user in order to complete the goal.
            /// </summary>
            [SerializeField]
            public GameObject stepObject;

            /// <summary>
            /// The text to display on the button shown in the step instructions.
            /// </summary>
            [SerializeField]
            public string buttonText;

            /// <summary>
            /// This indicates whether to show an additional button to skip the current goal/step.
            /// </summary>
            [SerializeField]
            public bool includeSkipButton;
        }

        [Tooltip("List of Goals/Steps to complete as part of the user onboarding.")]
        [SerializeField]
        List<Step> m_StepList = new List<Step>();

        /// <summary>
        /// List of Goals/Steps to complete as part of the user onboarding.
        /// </summary>
        public List<Step> stepList
        {
            get => m_StepList;
            set => m_StepList = value;
        }

        [Tooltip("Object Spawner used to detect whether the spawning goal has been achieved.")]
        [SerializeField]
        ObjectSpawner m_ObjectSpawner;

        /// <summary>
        /// Object Spawner used to detect whether the spawning goal has been achieved.
        /// </summary>
        public ObjectSpawner objectSpawner
        {
            get => m_ObjectSpawner;
            set => m_ObjectSpawner = value;
        }

        [Tooltip("The greeting prompt Game Object to show when onboarding begins.")]
        [SerializeField]
        GameObject m_GreetingPrompt;

        /// <summary>
        /// The greeting prompt Game Object to show when onboarding begins.
        /// </summary>
        public GameObject greetingPrompt
        {
            get => m_GreetingPrompt;
            set => m_GreetingPrompt = value;
        }

        [Tooltip("The Options Button to enable once the greeting prompt is dismissed.")]
        [SerializeField]
        GameObject m_OptionsButton;

        /// <summary>
        /// The Options Button to enable once the greeting prompt is dismissed.
        /// </summary>
        public GameObject optionsButton
        {
            get => m_OptionsButton;
            set => m_OptionsButton = value;
        }

        // [Tooltip("The Create Button to enable once the greeting prompt is dismissed.")]
        // [SerializeField]
        // GameObject m_CreateButton;

        // /// <summary>
        // /// The Create Button to enable once the greeting prompt is dismissed.
        // /// </summary>
        // public GameObject createButton
        // {
        //     get => m_CreateButton;
        //     set => m_CreateButton = value;
        // }

        [Tooltip("The AR Template Menu Manager object to enable once the greeting prompt is dismissed.")]
        [SerializeField]
        ARTemplateMenuManager m_MenuManager;

        /// <summary>
        /// The AR Template Menu Manager object to enable once the greeting prompt is dismissed.
        /// </summary>
        public ARTemplateMenuManager menuManager
        {
            get => m_MenuManager;
            set => m_MenuManager = value;
        }

        const int k_NumberOfSurfacesTappedToCompleteGoal = 1;

        Queue<Goal> m_OnboardingGoals;
        Goal m_CurrentGoal;
        bool m_AllGoalsFinished;
        bool m_IsCompletingGoal;
        bool m_IsPlaneListenerRegistered;
        int m_SurfacesTapped;
        int m_CurrentGoalIndex = 0;

        [SerializeField]
        [Tooltip("Required movement distance (meters) to complete the move step.")]
        float m_MoveCompletionDistance = 0.01f;

        [SerializeField]
        [Tooltip("Required rotation delta (degrees) to complete the rotate step.")]
        float m_RotationCompletionAngle = 10f;

        GameObject m_CurrentSpawnedObject;
        Vector3 m_MoveStartPosition;
        Vector3 m_MoveStartLocalPosition;
        Vector3 m_MoveStartBoundsCenter;
        bool m_HasMoveStartBoundsCenter;
        Quaternion m_RotateStartRotation;

        void Update()
        {
            if (m_AllGoalsFinished)
                return;

            if (m_CurrentGoal.CurrentGoal == OnboardingGoals.Hints && HasMovedEnough())
            {
                CompleteGoal();
            }
            else if (m_CurrentGoal.CurrentGoal == OnboardingGoals.Scale && HasRotatedEnough())
            {
                CompleteGoal();
            }
        }

        void OnDisable()
        {
            CleanupGoalHandlers();
        }

        void CompleteGoal()
        {
            if (m_IsCompletingGoal || m_AllGoalsFinished)
                return;

            m_IsCompletingGoal = true;
            CleanupGoalHandlers();

            try
            {
                m_CurrentGoal.Completed = true;
                m_CurrentGoalIndex++;

                var previousStepIndex = m_CurrentGoalIndex - 1;
                if (previousStepIndex >= 0 && previousStepIndex < m_StepList.Count)
                    m_StepList[previousStepIndex].stepObject.SetActive(false);

                if (m_OnboardingGoals.Count > 0)
                {
                    m_CurrentGoal = m_OnboardingGoals.Dequeue();

                    if (m_CurrentGoalIndex < m_StepList.Count)
                        m_StepList[m_CurrentGoalIndex].stepObject.SetActive(true);

                    PreprocessGoal();
                }
                else
                {
                    m_AllGoalsFinished = true;
                }
            }
            finally
            {
                m_IsCompletingGoal = false;
            }

        }

        void CleanupGoalHandlers()
        {
            if (m_ObjectSpawner != null)
                m_ObjectSpawner.objectSpawned -= OnObjectSpawned;

            if (m_IsPlaneListenerRegistered && m_MenuManager != null && m_MenuManager.planeManager != null)
            {
                m_MenuManager.planeManager.trackablesChanged.RemoveListener(OnPlaneTrackablesChanged);
                m_IsPlaneListenerRegistered = false;
            }
        }

        void PreprocessGoal()
        {
            if (m_CurrentGoal.CurrentGoal == OnboardingGoals.FindSurfaces)
            {
                RegisterPlaneListener();

                if (m_MenuManager != null && m_MenuManager.planeManager != null && m_MenuManager.planeManager.trackables.count > 0)
                    CompleteGoal();
            }
            else if (m_CurrentGoal.CurrentGoal == OnboardingGoals.Hints)
            {
                CacheMoveStartPose();
            }
            else if (m_CurrentGoal.CurrentGoal == OnboardingGoals.Scale)
            {
                if (m_CurrentSpawnedObject != null)
                    m_RotateStartRotation = m_CurrentSpawnedObject.transform.rotation;
            }
            else if (m_CurrentGoal.CurrentGoal == OnboardingGoals.TapSurface)
            {
                m_SurfacesTapped = 0;
                if (m_ObjectSpawner != null)
                    m_ObjectSpawner.objectSpawned += OnObjectSpawned;
            }
        }

        void RegisterPlaneListener()
        {
            if (m_MenuManager == null || m_MenuManager.planeManager == null)
                return;

            if (!m_IsPlaneListenerRegistered)
            {
                m_MenuManager.planeManager.trackablesChanged.AddListener(OnPlaneTrackablesChanged);
                m_IsPlaneListenerRegistered = true;
            }
        }

        void OnPlaneTrackablesChanged(ARTrackablesChangedEventArgs<ARPlane> eventArgs)
        {
            if (m_AllGoalsFinished || m_CurrentGoal.CurrentGoal != OnboardingGoals.FindSurfaces)
                return;

            if (eventArgs.added.Count > 0)
                CompleteGoal();
        }

        bool HasMovedEnough()
        {
            if (m_CurrentSpawnedObject == null)
                return false;

            var worldDelta = Vector3.Distance(m_MoveStartPosition, m_CurrentSpawnedObject.transform.position);
            var localDelta = Vector3.Distance(m_MoveStartLocalPosition, m_CurrentSpawnedObject.transform.localPosition);
            var maxDelta = Mathf.Max(worldDelta, localDelta);

            if (TryGetBoundsCenter(m_CurrentSpawnedObject, out var currentBoundsCenter) && m_HasMoveStartBoundsCenter)
                maxDelta = Mathf.Max(maxDelta, Vector3.Distance(m_MoveStartBoundsCenter, currentBoundsCenter));

            return maxDelta >= Mathf.Max(0.001f, m_MoveCompletionDistance);
        }

        void CacheMoveStartPose()
        {
            if (m_CurrentSpawnedObject == null)
                return;

            m_MoveStartPosition = m_CurrentSpawnedObject.transform.position;
            m_MoveStartLocalPosition = m_CurrentSpawnedObject.transform.localPosition;
            m_HasMoveStartBoundsCenter = TryGetBoundsCenter(m_CurrentSpawnedObject, out m_MoveStartBoundsCenter);
        }

        bool TryGetBoundsCenter(GameObject target, out Vector3 center)
        {
            var renderers = target.GetComponentsInChildren<Renderer>();
            if (renderers == null || renderers.Length == 0)
            {
                center = Vector3.zero;
                return false;
            }

            var bounds = renderers[0].bounds;
            for (int i = 1; i < renderers.Length; i++)
                bounds.Encapsulate(renderers[i].bounds);

            center = bounds.center;
            return true;
        }

        bool HasRotatedEnough()
        {
            return m_CurrentSpawnedObject != null &&
                   Quaternion.Angle(m_RotateStartRotation, m_CurrentSpawnedObject.transform.rotation) >= m_RotationCompletionAngle;
        }

        /// <summary>
        /// Forces the completion of the current goal and moves to the next.
        /// </summary>
        public void ForceCompleteGoal()
        {
            CompleteGoal();
        }

        void OnObjectSpawned(GameObject spawnedObject)
        {
            m_CurrentSpawnedObject = spawnedObject;
            m_SurfacesTapped++;
            if (m_CurrentGoal.CurrentGoal == OnboardingGoals.TapSurface && m_SurfacesTapped >= k_NumberOfSurfacesTappedToCompleteGoal)
            {
                CompleteGoal();
            }
        }

        /// <summary>
        /// Triggers a restart of the onboarding/coaching process.
        /// </summary>
        public void StartCoaching()
        {
            CleanupGoalHandlers();

            if (m_OnboardingGoals != null)
            {
                m_OnboardingGoals.Clear();
            }

            m_OnboardingGoals = new Queue<Goal>();

            var findSurfaceGoal = new Goal(OnboardingGoals.FindSurfaces);
            int startingStep = 0;

            var tapSurfaceGoal = new Goal(OnboardingGoals.TapSurface);
            var translateHintsGoal = new Goal(OnboardingGoals.Hints);
            var scaleHintsGoal = new Goal(OnboardingGoals.Scale);

            m_OnboardingGoals.Enqueue(findSurfaceGoal);
            m_OnboardingGoals.Enqueue(tapSurfaceGoal);
            m_OnboardingGoals.Enqueue(translateHintsGoal);
            m_OnboardingGoals.Enqueue(scaleHintsGoal);

            m_CurrentGoal = m_OnboardingGoals.Dequeue();
            m_AllGoalsFinished = false;
            m_CurrentGoalIndex = startingStep;
            m_CurrentSpawnedObject = null;

            if (m_GreetingPrompt != null)
                m_GreetingPrompt.SetActive(false);

            if (m_OptionsButton != null)
                m_OptionsButton.SetActive(true);

            if (m_MenuManager != null)
                m_MenuManager.enabled = true;

            for (int i = 0; i < m_StepList.Count; i++)
            {
                if (i == startingStep)
                {
                    m_StepList[i].stepObject.SetActive(true);
                }
                else
                {
                    m_StepList[i].stepObject.SetActive(false);
                }
            }

            PreprocessGoal();

        }
    }
}
