package org.zeorck.service;

import static org.junit.Assert.assertNotNull;

import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.junit4.SpringJUnit4ClassRunner;
import org.zerock.domain.BoardVO;
import org.zerock.domain.Criteria;
import org.zerock.service.BoardService;

import lombok.Setter;
import lombok.extern.log4j.Log4j;

@RunWith(SpringJUnit4ClassRunner.class)
@ContextConfiguration("file:src/main/webapp/WEB-INF/spring/root-context.xml")
@Log4j
public class BoardServiceTests {

	@Setter(onMethod_ = @Autowired)
	private BoardService service;
	
	@Test
	public void testExist() {
		log.info(service);
		assertNotNull(service);
	}
	
	@Test
	public void 테스트등록() {
		BoardVO board = new BoardVO();
		board.setTitle("새로 작성하는 글");
		board.setContent("새로 작성하는 내용");
		board.setWriter("키키키키키키");
		service.register(board);
		log.info("생성딘 게시물의 번호: " + board.getBno());
		
	}
	
	@Test
	public void 테스트겟리스트() {
		service.getList(new Criteria(2, 10)).forEach(board -> log.info(board));
	}
	
	@Test
	public void 테스트특정셀렉트() {
		log.info(service.get(1L));
	}
	
	@Test
	public void 테스트삭제() {
		
		log.info("Remove result: " + service.remove(2121212L));
		
		
	}
	
	@Test
	public void 테스트수정() {
		BoardVO board = service.get(1L);
		
		if (board == null) {
			return;
		}
		
		board.setTitle("제목 수정한다ㅡㅡㅡㅡㅡㅡ");
		log.info("Modify result: " + service.modify(board));
		
	}
	
	
}
