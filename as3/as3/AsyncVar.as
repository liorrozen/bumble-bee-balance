package as3{
	public class AsyncVar{
		private var m_callBack :Function
		private var m_data:*;
		public function AsyncVar(){
			//
		}
		public function set data(p_data:*):void{
			if (m_data != null){
				 throw new Error("Cant set data value more than once!");
			}
			else{
				m_data = p_data;
			}
			m_callBack.call(null,p_data);
		}
		
		public function get data():*{
			return m_data;
		}
		
		public function setHandler(func:Function):void{
			m_callBack = func;
		}
		

	}
}