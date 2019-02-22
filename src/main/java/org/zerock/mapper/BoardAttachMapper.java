package org.zerock.mapper;

import java.util.List;

import org.zerock.domain.BoardAttachVO;

public interface BoardAttachMapper {
	void insert(BoardAttachVO vo);
	void delete(String uuid);
	List<BoardAttachVO> findByBno(Long bno);
	void deleteAll(Long bno);
	
}
