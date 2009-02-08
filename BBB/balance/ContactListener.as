package balance
{
	import Box2D.Collision.b2ContactPoint;
	import Box2D.Dynamics.b2ContactListener;

	public class ContactListener extends b2ContactListener
	{
		private var m_manager : GameManager;
		
		public function ContactListener(gm : GameManager)
		{
			m_manager = gm;
			super();
		}
		
		/// Called when a contact point is added. This includes the geometry
		/// and the forces.
 		override public function Add(point:b2ContactPoint) : void{
			var obj1 : GameObject = point.shape1.m_body.GetUserData();
			var obj2 : GameObject = point.shape2.m_body.GetUserData();
			if(obj1 != null && obj2 != null) {
				if(obj1 is Platform || obj1 is Block) {
					if(obj2 is Player) {
						Player(obj2).contactCount++
					}
					
					if (obj1 is Platform && point.shape2.IsSensor())
					{
						if (!m_manager.sensorActive) {
							m_manager.sensorActive = true;
							m_manager.startCalculatingScore();
						}
					}
					
				} else if(obj2 is Platform || obj2 is Block) {
					if(obj1 is Player) {
						Player(obj1).contactCount++
					}	
					
					if (obj2 is Platform && point.shape1.IsSensor())
					{
						if (!m_manager.sensorActive) {
							m_manager.sensorActive = true;
							m_manager.startCalculatingScore();
						}
					}
				}
			}
		} 
		
		/// Called when a contact point persists. This includes the geometry
		/// and the forces.
		//override public function Persist(point:b2ContactPoint) : void{}
	
		/// Called when a contact point is removed. This includes the last
		/// computed geometry and forces.
 		override public function Remove(point:b2ContactPoint) : void{
			var obj1 : GameObject = point.shape1.m_body.GetUserData();
			var obj2 : GameObject = point.shape2.m_body.GetUserData();
			if(obj1 != null && obj2 != null) {
				if(obj1 is Platform || obj1 is Block) {
					if(obj2 is Player) {
						Player(obj2).contactCount--
						/*if(Player(obj2).contactCount == 0) {
							Player(obj2).isJumping = false;
						}*/
					}
					
					if (obj1 is Platform && point.shape2.IsSensor())
					{
						m_manager.stopCalculatingScore();
					}
					
				} else if(obj2 is Platform || obj2 is Block) {
					if(obj1 is Player) {
						Player(obj1).contactCount--
						/*if(Player(obj1).contactCount == 0) {
							Player(obj1).isJumping = false;
						}*/
					}
					
					if (obj2 is Platform && point.shape1.IsSensor())
					{
						m_manager.stopCalculatingScore();
					}
				}
			}
		}
		
		// Called after a contact point is solved.
		//override public function Result(point:b2ContactResult) : void {}
	}		
}