package org.zerock.aop;

import java.util.Arrays;

import org.aspectj.lang.ProceedingJoinPoint;
import org.aspectj.lang.annotation.AfterThrowing;
import org.aspectj.lang.annotation.Around;
import org.aspectj.lang.annotation.Aspect;
import org.aspectj.lang.annotation.Before;
import org.springframework.stereotype.Component;

import lombok.extern.log4j.Log4j;

/**
 * AOP 기능의 설정은 XML 방식도 있지만 이 책에서는 어노테이션 방식만을 이용 
 * @author ChoiSangHyun
 *
 */

@Aspect
@Log4j
@Component
public class LogAdvise {
	
	// AspectJ의 ㅍ현식!
	// 맨 앞 * 는 접근제한자, 맨 뒤의 *는 클래스 이름과 메서드를 의미
	// * 는 모든 값, .. 는 0개 이상을 의미
	// execution([수식어] [리턴타입] [클래스이름] [이름]([파라미터]))
	/**
	 *  수식어: public, protected 등등 - 생략 가능
	 */
	@Before("execution(* org.zerock.service.SampleService*.*(..))")
	public void logBefore() {
		log.info("==================================");
	}
	
	// && args 를 이용하는 설정은 간단히  파라미터를 찾아서 기록할 때는 유용하다.
	// 그러나 파라미터가 다른 여러 종류의 메서드에 적용하는 데에는 간단하지 않다는 단점이 있다. -> 공유 변수?
	// 이러한 단점은 @Around와 ProceedingJoinPoint 를 이용해서 해결
	@Before("execution(* org.zerock.service.SampleService*.doAdd(String, String)) && args(str1, str2)")
	public void logBeforeWithParam(String str1, String str2) {
		// str1 += 5555555; // 적용 X
		log.info("str1: " + str1);
		log.info("str2: " + str2);
	}
	
	// 코드 실행시 파라미터 값이 잘못되어 예외 발생하는 경우 @AfterThrowing를 이용하여 예외 발생 후 동작하면서 문제를 찾을 수 있다.
	@AfterThrowing(pointcut= "execution(* org.zerock.service.SampleService*.*(..))", throwing="exception")
	public void logException(Exception exception) {
		log.info("Exception!!!!!!!!!!");
		log.info("exception: " + exception);
	}
	
	// AOP를 이용해 더 구체적인 처리를 위해 @Around와 ProceedingJoinPoint 사용
	// 1. @Arount: 직접 대상 메서드를 실행할 수 있는 권한을 가지고 있고, 메서드 실행 전, 후 처리가 가능
	// 2. @ProceedingJoinPoint: @Aroung와 같이 결합해서 파라미터나 예외 등을 처리할 수 있다.
	//		- AOP의 대상이 되는 Target이나 파라미터 등을 파악할 뿐만 아니라 직접 실행을 결정할 수 있다.
	// @Around가 먼저 동작하고 @Before 동작
	@Around("execution(* org.zerock.service.SampleService*.*(..))")
	public Object logTime(ProceedingJoinPoint pjp) {
		long start = System.currentTimeMillis();
		
		log.info("Target: " + pjp.getTarget());
		log.info("Param: " + Arrays.toString(pjp.getArgs()));
		
		// invoke method
		Object result = null;
		
		try {
			
		} catch (Throwable e) {
			e.printStackTrace();
		}
		
		long end = System.currentTimeMillis();
		
		log.info("TIME: " + (end - start));
		return result;
	}
	
}
