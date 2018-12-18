package org.zerock.controller;

import org.junit.Before;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.junit4.SpringJUnit4ClassRunner;
import org.springframework.test.context.web.WebAppConfiguration;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.request.MockMvcRequestBuilders;
import org.springframework.test.web.servlet.setup.MockMvcBuilders;
import org.springframework.web.context.WebApplicationContext;
import org.springframework.web.method.support.ModelAndViewContainer;

import lombok.Setter;
import lombok.extern.log4j.Log4j;

@RunWith(SpringJUnit4ClassRunner.class)
@WebAppConfiguration
@ContextConfiguration({"file:src/main/webapp/WEB-INF/spring/root-context.xml",
					   "file:src/main/webapp/WEB-INF/spring/appServlet/servlet-context.xml"})
@Log4j
public class BoardControllerTests {

	@Setter(onMethod_ = {@Autowired})
	private WebApplicationContext ctx;
	
	private MockMvc mockMvc;
	
	@Before
	public void setup() {
		this.mockMvc = MockMvcBuilders.webAppContextSetup(ctx).build();
	}

	@Test
	public void testList() throws Exception {
		log.info(mockMvc.perform(MockMvcRequestBuilders.get("/board/list"))
				 .andReturn()
				 .getModelAndView()
				 .getModelMap());
	}
	
	@Test
	public void testRegister() throws Exception {
		String resultPage = mockMvc.perform(MockMvcRequestBuilders.post("/board/register")
								.param("title", "테스트 새그으으으으으을 제오모모옥")
								.param("content", "테스트 새글 내요오오옹")
								.param("writer", "user0000000000"))
							.andReturn()
							.getModelAndView()
							.getViewName();
		
		log.info("testtttt: " + resultPage);
						
	}
	
	@Test
	public void testGet() throws Exception {
		log.info(mockMvc.perform(MockMvcRequestBuilders
										.get("/board/get")
										.param("bno", "11"))
									.andReturn()
									.getModelAndView().getModelMap());
	}
	
	@Test
	public void testModify() throws Exception {
		String resultPage = mockMvc.perform(MockMvcRequestBuilders
										.post("/board/modify")
										.param("bno", "11")
										.param("title", "수저어어어엉 제목")
										.param("content", "수저어어어어엉내용")
										.param("writer", "user000000012312312"))
									.andReturn()
									.getModelAndView().getViewName();
		
		log.info(resultPage);
	}
	
	@Test
	public void testDelete() throws Exception{
		String resultPage = mockMvc.perform(MockMvcRequestBuilders.post("/board/delete")
													.param("bno", "25"))
												.andReturn()
												.getModelAndView()
												.getViewName();
		
		log.info(resultPage);
				
		
	}
	
	
	
}
