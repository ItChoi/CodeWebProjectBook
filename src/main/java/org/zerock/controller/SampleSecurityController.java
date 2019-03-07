package org.zerock.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

import lombok.extern.log4j.Log4j;

@Log4j
@RequestMapping("/sample/*")
@Controller
public class SampleSecurityController {
	
		// 시큐리티 관련 uri 설계
		@GetMapping("/all")
		public void doAll() {
			log.info("do all can access everybody");
		}

		@GetMapping("/member")
		public void doMember() {
			log.info("logined member");
		}
		
		@GetMapping("/admin")
		public void doAdmin() {
			log.info("admin only");
		}
}
