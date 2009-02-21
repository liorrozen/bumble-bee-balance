package balance
{
	import Box2D.Collision.Shapes.b2CircleDef;
	import Box2D.Collision.Shapes.b2PolygonDef;
	import Box2D.Common.Math.b2Math;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.Joints.b2RevoluteJoint;
	import Box2D.Dynamics.Joints.b2RevoluteJointDef;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2BodyDef;
	import Box2D.Dynamics.b2World;
	import Box2D.Collision.Shapes.b2Shape;
	
	import as3.AssetManager.AssetManager;
	
	import flash.display.MovieClip;
	import flash.events.*;

	public class Player extends GameObject
	{
		
		private var m_wheel1 : b2Body;
		private var m_wheel2 : b2Body;
		private var m_carBody : b2Body;
		private var m_joint1 : b2RevoluteJoint;
		private var m_joint2 : b2RevoluteJoint;
		protected var m_manager : GameManager;
		private var m_speedMod : Number = 3;
		
		public var pname : String;
		public var team : uint;
		public var spawn_point : b2Vec2;
		public var isJumping : Boolean = false;
		public var contactCount : int = 0;
		public var powerUp : String;
		
		public function Player( world:b2World,
					position : b2Vec2,
					manager : GameManager,
					p_team : uint,
					p_name : String )
		{
			super(world);
			pname = p_name
			m_manager = manager
			spawn_point = position.Copy()
			team = p_team;
			
			var carDef : b2BodyDef = new b2BodyDef();
			carDef.position.x = position.x;
			carDef.position.y = position.y;
			m_carBody = m_world.CreateBody(carDef);
			var carShapeDef : b2PolygonDef = new b2PolygonDef();
			carShapeDef.filter.groupIndex = -1;
			carShapeDef.SetAsBox(3.2/2,0.5/2);
			carShapeDef.density = 1;
			carShapeDef.friction = 1000;
			m_carBody.CreateShape(carShapeDef);
			m_carBody.SetMassFromShapes();
			m_carBody.SetUserData(this)
			
			var wheel1Def : b2BodyDef = new b2BodyDef();
			wheel1Def.position.x = position.x + 
				Number(GameManager.dictionary.getParamByName('playerWheelDistance')) / 2;
			wheel1Def.position.y = position.y;
			m_wheel1 = m_world.CreateBody(wheel1Def);
			var wheel1ShapeDef : b2CircleDef = new b2CircleDef();
			wheel1ShapeDef.filter.groupIndex = -1;
			wheel1ShapeDef.radius =
				Number(GameManager.dictionary.getParamByName('playerWheelRadius'));
			wheel1ShapeDef.density = 1;
			wheel1ShapeDef.friction = 
				Number(GameManager.dictionary.getParamByName('playerWheelFriction'));
			wheel1ShapeDef.restitution = 0;
			m_wheel1.CreateShape(wheel1ShapeDef);
			m_wheel1.SetMassFromShapes();
			m_wheel1.SetUserData(this)
			
			var wheel2Def : b2BodyDef = new b2BodyDef();
			wheel2Def.position.x = position.x - 
				Number(GameManager.dictionary.getParamByName('playerWheelDistance')) / 2;
			wheel2Def.position.y = position.y;
			m_wheel2 = m_world.CreateBody(wheel2Def);
			var wheel2ShapeDef : b2CircleDef = new b2CircleDef();
			wheel2ShapeDef.filter.groupIndex = -1;
			wheel2ShapeDef.radius =
				Number(GameManager.dictionary.getParamByName('playerWheelRadius'));
			wheel2ShapeDef.density = 1;
			wheel2ShapeDef.friction = 
				Number(GameManager.dictionary.getParamByName('playerWheelFriction'));
			wheel2ShapeDef.restitution = 0;
			m_wheel2.CreateShape(wheel2ShapeDef);
			m_wheel2.SetMassFromShapes();
			m_wheel2.SetUserData(this)
			
			var joint1Def : b2RevoluteJointDef = new b2RevoluteJointDef();
			joint1Def.Initialize(m_wheel1, m_carBody, m_wheel1.GetWorldCenter());
			joint1Def.enableMotor = true;
			joint1Def.motorSpeed = 0;
			joint1Def.maxMotorTorque = 100000;
			m_joint1 = m_world.CreateJoint(joint1Def) as b2RevoluteJoint;
			
			var joint2Def : b2RevoluteJointDef = new b2RevoluteJointDef();
			joint2Def.Initialize(m_wheel2, m_carBody, m_wheel2.GetWorldCenter());
			joint2Def.enableMotor = true;
			joint2Def.motorSpeed = 0;
			joint2Def.maxMotorTorque = 100000;
			m_joint2 = m_world.CreateJoint(joint2Def) as b2RevoluteJoint;
			
			m_body = m_carBody;
			
			createGUI();
			
			addEventListener(Event.ADDED_TO_STAGE, addedHandler);
		}
		
		public function addedHandler(e:Event):void {
			createGUI();
		}
		
		override public function get bodies() : Array {
			var tmpbArr : Array = super.bodies;
			tmpbArr.push(m_wheel1);
			tmpbArr.push(m_wheel2);
			return tmpbArr;
		}
		
		override protected function createShape() : void
		{
		}
		
		public function set speed(n : Number):void {
			n*=m_speedMod
			if(m_carBody.IsSleeping())
				m_carBody.WakeUp();
			m_joint1.SetMotorSpeed(n)
			m_joint2.SetMotorSpeed(n)
		}
		
		public function jump():void {
			// Get vector in the anti direction to gravity
			var agvec : b2Vec2 = m_world.m_gravity.Negative();
			
			// Find it's perpendicular unit vector
			var perpvec : b2Vec2 = agvec.Copy();
			perpvec.CrossFV(1);
			perpvec.Normalize();
			
			// Get cos(angle) of current velocity vector and perp. vector
			m_carBody.GetLinearVelocity().Normalize();
			var cosAlpha : Number =
				b2Math.b2Dot(m_carBody.GetLinearVelocity(), perpvec);
			
			// Get the length of curr velocity vector
			var currVelocityLen : Number =
				m_carBody.GetLinearVelocity().Normalize();
			
			// Scale the perp. vector to the amount of velocity
			// in the direction.
			perpvec.Multiply(currVelocityLen * cosAlpha);
			
			// Scale the anti-gravity velocity according to requied
			// factor
			agvec.Multiply(
				Number(GameManager.dictionary.getParamByName('playerJumpFactor')));
			
			// Add only this component to the required jump velocity
			// vector to preserve sideways velocity.
			agvec.Add(perpvec);
			
			// Set the cars new velocity.
			m_carBody.SetLinearVelocity(agvec);
			
			//m_carBody.ApplyImpulse(vec,m_carBody.GetWorldCenter());
		}
		
		public function usePowerUp():void {
			switch(powerUp) {
				case "weight++":
					m_carBody.GetShapeList().m_density = 2;
					m_carBody.SetMassFromShapes();
				break;
				case "weight--":
					m_carBody.GetShapeList().m_density = 0.5;
					m_carBody.SetMassFromShapes();
				break;
				case "speed++":
					m_speedMod = 1.5
				break;
				case "pull":
					runPull();
				break;
				case "push":
					runPush();
				break;
			}
			powerUp = "";
		}
		
		private function runPush() : void {
			var player : Player = getclosePlayer();
			var dir : b2Vec2 = new b2Vec2(player.x,player.y)
			dir.Subtract(new b2Vec2(x,y))
			player.pushed(dir)
		}
		
		public function pushed(dir : b2Vec2) : void {
			dir.Normalize();
			dir.Multiply(80)
			dir.Add(new b2Vec2(0,-4))
			m_carBody.ApplyImpulse(dir,m_carBody.GetWorldCenter())
		}
		
		private function runPull() : void {
			var player : Player = getclosePlayer();
			var dir : b2Vec2 = new b2Vec2(player.x,player.y)
			dir.Subtract(new b2Vec2(x,y))
			player.pulled(dir)
		}
		
		public function pulled(dir : b2Vec2) : void {
			dir.Normalize();
			dir.Multiply(-80)
			dir.Add(new b2Vec2(0,-4))
			m_carBody.ApplyImpulse(dir,m_carBody.GetWorldCenter())
		}
		
		private function getclosePlayer() : Player {
			var players : Array = m_manager.players
			var minPlayer : Player
			for each(var player : Player in players) {
				if(player != this) {
					if(minPlayer == null) {
						minPlayer = player
					} else if(distance(player.x,player.y)<distance(minPlayer.x,minPlayer.y)) {
						minPlayer = player;
					}
				}
			}
			return minPlayer
		}
		
		override protected function createGUI():void {	
			m_gui = AssetManager.getInstance().getAssetByName(team==1 ? 'car1_gui':'car2_gui');
			var scalePic : Number =
				(3.2) * Number(GameManager.dictionary.getParamByName('worldScale')) / m_gui.width;
			m_gui.scaleX = scalePic;
			m_gui.scaleY = scalePic;
			m_gui.y = -10;
			m_gui.gotoAndStop(2);
			this.addChild(m_gui);
		}
		
		override public function update():void {
			x = m_carBody.GetPosition().x * Number(GameManager.dictionary.getParamByName('worldScale'));
			y = m_carBody.GetPosition().y * Number(GameManager.dictionary.getParamByName('worldScale'));
			rotation = m_carBody.GetAngle() * (180/Math.PI);
			for(var i : uint = m_manager.powerUps.length-1 ; i > 0 ; --i) {
				if(hitTestObject(m_manager.powerUps[i])) {
					powerUp = m_manager.powerUps[i].type;
					
					// Announce the UI that a power up change has occured
					dispatchEvent(new BalanceEvent(BalanceEvent.SET_POWERUP,pname,team,powerUp,0,true));
					
					m_manager.powerUps[i].parent.removeChild(m_manager.powerUps[i])
					m_manager.powerUps.splice(i,1)
				}
			}
		}
		
		protected function distance(x1 : Number, y1 : Number) : Number {
			return Math.sqrt((x1-x)*(x1-x)+(y1-y)*(y1-y))
		}
	}
}