package org.zerock.controller;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;
import org.zerock.domain.BoardVO;
import org.zerock.domain.Criteria;
import org.zerock.domain.PageDTO;
import org.zerock.service.BoardService;

import lombok.AllArgsConstructor;
import lombok.extern.log4j.Log4j;

@Controller
@Log4j
@RequestMapping("/board/*")
@AllArgsConstructor
public class BoardController {

	private BoardService service;
	
	
	@GetMapping("/list")
	public void list(Criteria cri, Model model) {
		log.info("lists zzzzzzzzz: " + cri);
		// model.addAttribute("test", "test123");
		model.addAttribute("list", service.getList(cri));
		// PageDTO page = new PageDTO(cri, 123);
		int total = service.getTotal(cri);
		log.info("total: " + total);
		PageDTO page = new PageDTO(cri, total);
		model.addAttribute("pageMaker", page);
		System.out.println("------------------test start------------------");
		System.out.println("getStartPage: " + page.getStartPage());
		System.out.println("getEndPage: " + page.getEndPage());
		System.out.println("getTotal: " + page.getTotal());
		System.out.println("getAmount: " + page.getCri().getAmount());
		System.out.println("getPageNum: " + page.getCri().getPageNum());
		System.out.println("------------------test end------------------");
	}
	
	@GetMapping("register")
	public void register() {
		
	}
	
	@PostMapping("/register")
	public String register(BoardVO board, RedirectAttributes rttr) {
		
		log.info("register: " + board);
		
		service.register(board);
		
		rttr.addFlashAttribute("result", board.getBno());
		
		return "redirect:/board/list";
	}
	
	@GetMapping({"/get", "modify"})
	public void get(@RequestParam("bno") Long bno, Model model, @ModelAttribute("cri") Criteria cri) {
		log.info("/get");
		model.addAttribute("board", service.get(bno));
	}
	
	@PostMapping("/modify")
	public String modify(BoardVO board, RedirectAttributes rttr, @ModelAttribute("cri") Criteria cri) {
		log.info("modify: " + board);
		
		if (service.modify(board)) {
			System.out.println("성공입니닷사사삿");
			rttr.addAttribute("result", "success");
		}
		
		rttr.addAttribute("pageNum", cri.getPageNum());
		rttr.addAttribute("amount", cri.getAmount());
		
		return "redirect:/board/list";
	}
	
	@PostMapping("/delete")
	public String delete(@RequestParam("bno") Long bno, RedirectAttributes rttr, @ModelAttribute("cri") Criteria cri) {
		
		System.out.println("여기는 삭제인데????");
		log.info("remove: " + bno);
		if (service.remove(bno)) {
			rttr.addAttribute("result", "success");
		}
		
		rttr.addAttribute("pageNum", cri.getPageNum());
		rttr.addAttribute("amount", cri.getAmount());
		
		return "redirect:/board/list";
	}
	
}
