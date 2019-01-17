package org.zerock.domain;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
// 빈 생성자와 모든 속성을 담은 생성자 생성
public class SampleVO {
	
	private Integer mno;
	private String firstName;
	private String lastName;
	
}
