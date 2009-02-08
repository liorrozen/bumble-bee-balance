package balance
{
	import Box2D.Collision.Shapes.b2Shape;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2BodyDef;
	import Box2D.Dynamics.b2World;
	import flash.display.MovieClip;
	import flash.display.Sprite;

	public class GameObject extends Sprite
	{
		protected var m_world : b2World;
		protected var m_body : b2Body;
		protected var m_shape : b2Shape;
		protected var m_gui : MovieClip;
		
		public function GameObject(world : b2World, bodyDef : b2BodyDef = null)
		{
			m_world = world
			if(bodyDef != null) {
				m_body = m_world.CreateBody(bodyDef);
				m_body.SetUserData(this);
			}
			
			super();
		}
		
		public function get isFrozen():Boolean {
			return m_body.IsFrozen()
		}
		
		public function get bodies() : Array {
			var tmpbArr : Array = new Array();
			tmpbArr.push(m_body);
			return tmpbArr;
		}
		
		public function update() : void {
			x = m_body.GetPosition().x * Number(GameManager.dictionary.getParamByName('worldScale'));
			y = m_body.GetPosition().y * Number(GameManager.dictionary.getParamByName('worldScale'));
			rotation = m_body.GetAngle() * (180/Math.PI);
		}
		
		protected function createShape() : void
		{
			throw new Error("call abstract");
		}
		
		protected function createGUI() : void {
			throw new Error("call abstract");
		}
	}
}