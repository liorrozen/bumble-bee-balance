package balance
{
	import Box2D.Collision.Shapes.b2PolygonDef;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.b2BodyDef;
	import Box2D.Dynamics.b2World;
	
	import as3.AssetManager.AssetManager;
	
	import flash.display.MovieClip;

	public class Block extends GameObject
	{
		public function Block(world:b2World, position : b2Vec2)
		{
			var Def : b2BodyDef = new b2BodyDef();
			Def.position.x = position.x;
			Def.position.y = position.y;
			super(world, Def);
			var ShapeDef : b2PolygonDef = new b2PolygonDef();
			ShapeDef.SetAsBox(2/2,2/2);
			ShapeDef.density = 1;
			ShapeDef.restitution = 0;
			ShapeDef.friction = 0.001;
			m_body.CreateShape(ShapeDef);
			m_body.SetMassFromShapes();
			createGUI()
		}
		
		override protected function createGUI():void {
			m_gui = AssetManager.getInstance().getAssetByName("object_gui")
			m_gui.width = 2 *
				Number(GameManager.dictionary.getParamByName('worldScale'));
			m_gui.height = 2 *
				Number(GameManager.dictionary.getParamByName('worldScale'));
			m_gui.x = 0;
			m_gui.y = 1 *
				Number(GameManager.dictionary.getParamByName('worldScale'));
			addChild(m_gui)
		}
		
		override public function update():void {
			x = m_body.GetPosition().x * Number(GameManager.dictionary.getParamByName('worldScale'));
			y = m_body.GetPosition().y * Number(GameManager.dictionary.getParamByName('worldScale'));
			rotation = m_body.GetAngle() * (180/Math.PI);
		}
		
	}
}