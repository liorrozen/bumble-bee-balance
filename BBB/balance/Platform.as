package balance
{
	import Box2D.Collision.Shapes.b2CircleDef;
	import Box2D.Collision.Shapes.b2PolygonDef;
	import Box2D.Dynamics.Joints.b2Joint;
	import Box2D.Dynamics.Joints.b2RevoluteJointDef;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2BodyDef;
	import Box2D.Dynamics.b2World;
	
	import as3.AssetManager.AssetManager;
	
	import flash.display.MovieClip;
	import flash.events.Event;

	public class Platform extends GameObject
	{ 
		private var m_anchorBody : b2Body;
		private var m_stopper1body : b2Body;
		private var m_stopper2body : b2Body;
		private var m_joint : b2Joint;
		private var m_goal1_gui : MovieClip;
		private var m_goal2_gui : MovieClip;
		
		public function Platform(world:b2World)
		{
			var bodyDef : b2BodyDef = new b2BodyDef();
			bodyDef.position.x = 20;
			bodyDef.position.y = 20;
			
			super(world, bodyDef);
			
			// Calculate the locatino of the two stoppers
			// to get the correct max rotation angle.
			var maxAngle : Number = Number(GameManager.dictionary.getParamByName('maxPlatformAngle')) * (Math.PI / 180);
			
			var x1 : Number = Math.cos(maxAngle) * 
				Number(GameManager.dictionary.getParamByName('platformLength')) / 2 * 0.8 + 20;
			var y1 : Number = Math.sin(maxAngle) *
				Number(GameManager.dictionary.getParamByName('platformLength')) / 2 * 0.8 + 20; 
				
			var x2 : Number = 20 - Math.cos(maxAngle) * 
				Number(GameManager.dictionary.getParamByName('platformLength')) / 2 * 0.8;
			var y2 : Number = Math.sin(maxAngle) *
				Number(GameManager.dictionary.getParamByName('platformLength')) / 2 * 0.8 + 20;
			
			// Create stopper 1 to limit the seesaw
			var stopper1bodyDef : b2BodyDef = new b2BodyDef();
			stopper1bodyDef.position.x = x1;
			stopper1bodyDef.position.y = y1;
			m_stopper1body = m_world.CreateBody(stopper1bodyDef);
			var stopper1Def : b2PolygonDef = new b2PolygonDef();
			stopper1Def.SetAsBox(.1, 0.1);
			stopper1Def.density = 0;
			stopper1Def.restitution = 0;
			stopper1Def.friction = 1000;
			//stopper1Def.filter.groupIndex = -9;
			// Add a sensor circle to stopper number 1 to determine
			// platform touch in the stopper radius
			var sens1:b2CircleDef = new b2CircleDef();
			sens1.density = 0;
			sens1.radius = Number(GameManager.dictionary.getParamByName('platformSensorRadius'));
			sens1.isSensor = true;
			sens1.filter.groupIndex = -9;
			m_stopper1body.CreateShape(sens1);
			m_stopper1body.CreateShape(stopper1Def);
			m_stopper1body.SetMassFromShapes();
			m_stopper1body.SetUserData(this);
			

			// Create stopper 2 to limit the seesaw
			var stopper2bodyDef : b2BodyDef = new b2BodyDef();
			stopper2bodyDef.position.x = x2;
			stopper2bodyDef.position.y = y2;
			m_stopper2body = m_world.CreateBody(stopper2bodyDef);
			var stopper2Def : b2PolygonDef = new b2PolygonDef();
			stopper2Def.SetAsBox(0.1, 0.1);
			stopper2Def.density = 0;
			stopper2Def.friction = 1000;
			//stopper2Def.filter.groupIndex = -9;
			// Add a sensor circle to stopper number 1 to determine
			// platform touch in the stopper radius
			var sens2:b2CircleDef = new b2CircleDef();
			sens2.density = 0;
			sens2.radius = Number(GameManager.dictionary.getParamByName('platformSensorRadius'));
			sens2.isSensor = true;
			sens2.filter.groupIndex = -9;
			m_stopper2body.CreateShape(sens2);
			m_stopper2body.CreateShape(stopper2Def);
			m_stopper2body.SetMassFromShapes();
			m_stopper2body.SetUserData(this);
			
			var anchorBodyDef : b2BodyDef = new b2BodyDef();
			anchorBodyDef.position.x = m_body.GetWorldCenter().x;
			anchorBodyDef.position.y = m_body.GetWorldCenter().y;
			m_anchorBody = m_world.CreateBody(anchorBodyDef);
			
			var jointDef : b2RevoluteJointDef = new b2RevoluteJointDef();
			jointDef.Initialize(m_body, m_anchorBody, m_anchorBody.GetWorldCenter());
			jointDef.referenceAngle = 0;
			jointDef.lowerAngle = 0.1;
			jointDef.upperAngle = -0.1;
			m_joint = m_world.CreateJoint(jointDef); 
			
			
			createShape();
			createGUI();
		}
		
		override protected function createShape() : void
		{
			var shapeDef : b2PolygonDef = new b2PolygonDef();
			shapeDef.SetAsBox(
				Number(GameManager.dictionary.getParamByName('platformLength')) /2,
				Number(GameManager.dictionary.getParamByName('platformHeight')) /2);
			shapeDef.density = 
				Number(GameManager.dictionary.getParamByName('platformDensity'));
			shapeDef.friction = 
				Number(GameManager.dictionary.getParamByName('platformFriction'));	
			shapeDef.restitution =
				Number(GameManager.dictionary.getParamByName('platformRestitution'));			
			
			m_body.CreateShape(shapeDef);
			m_body.SetMassFromShapes();
		}
		
		override protected function createGUI():void {
			m_gui = AssetManager.getInstance().getAssetByName('platform_gui');
			m_gui.width =
				Number(GameManager.dictionary.getParamByName('platformLength')) *
				Number(GameManager.dictionary.getParamByName('worldScale'));
			m_gui.height = 
				Number(GameManager.dictionary.getParamByName('platformHeight')) *
				Number(GameManager.dictionary.getParamByName('worldScale'));
			addChild(m_gui);
			
			m_goal1_gui = AssetManager.getInstance().getAssetByName('goal1_gui');
			m_goal1_gui.x = m_stopper1body.GetWorldCenter().x *
				Number(GameManager.dictionary.getParamByName('worldScale'));
			m_goal1_gui.y = m_stopper1body.GetWorldCenter().y * 
				Number(GameManager.dictionary.getParamByName('worldScale'));
			
			m_goal2_gui = AssetManager.getInstance().getAssetByName('goal2_gui');
			m_goal2_gui.x = m_stopper2body.GetWorldCenter().x *
				Number(GameManager.dictionary.getParamByName('worldScale'));
			m_goal2_gui.y = m_stopper2body.GetWorldCenter().y *
				Number(GameManager.dictionary.getParamByName('worldScale'));
			
			addEventListener(Event.ADDED, function _added(e : Event) {
				parent.addChild(m_goal1_gui);
				parent.addChild(m_goal2_gui);
			});
		}
	}
}