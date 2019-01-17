package org.zerock.domain;

import lombok.Builder;
import lombok.Data;

@Data
public class Ticket {
	private int tno;
	private String owner;
	private String grade;
}
