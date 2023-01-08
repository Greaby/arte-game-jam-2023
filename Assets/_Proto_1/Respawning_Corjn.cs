using UnityEngine;
using System.Collections;
using RootMotion.Dynamics;

namespace RootMotion.Demos {

	// Respawning BehaviourPuppet at a random position/rotation
	public class Respawning_Corjn : MonoBehaviour {

		public Transform pool;
		public BehaviourPuppet puppet;
		public string idleAnimation;

		private bool isPooled { get { return puppet.transform.root == pool; }}
		public Transform puppetRoot;

		void Start() {
			// Store the root Transform of the puppet

			// Deactivate the pool so anyhting parented to it would be deactivated too
			pool.gameObject.SetActive(false);
		}

		public void Pool() {
			puppetRoot.parent = pool;
		}

		public void Respawn(Vector3 position, Quaternion rotation) {
			puppet.puppetMaster.state = PuppetMaster.State.Alive;
            if (puppet.puppetMaster.targetAnimator.gameObject.activeInHierarchy) puppet.puppetMaster.targetAnimator.Play(idleAnimation, 0, 0f);
            puppet.SetState(BehaviourPuppet.State.Puppet);
			puppet.puppetMaster.Teleport(position, rotation, true);

			puppetRoot.parent = null;
		}
	}
}
