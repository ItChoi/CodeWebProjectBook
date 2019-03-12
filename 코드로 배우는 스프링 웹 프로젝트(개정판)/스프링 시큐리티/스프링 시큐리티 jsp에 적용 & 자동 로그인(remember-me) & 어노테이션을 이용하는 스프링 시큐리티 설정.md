# 스프링 시큐리티를 JSP에서 적용하기
굳이 CustomUserDetailsService와 같이 별도의 인증/권한 체크를 하는 가장 큰 이유는 JSP 등에서 단순히 사용자의 아이디(username) 정도가 아닌
사용자의 이름이나 이메일과 같은 추가적인 정보를 이용하기 위해서이다.

JSP에서 스프링 시큐리티를 적용하기 위해서는 pom.xml에 해당 태그 라이브러리 추가가 필요하다.
```xml
<dependency>
			<groupId>org.springframework.security</groupId>
			<artifactId>spring-security-taglibs</artifactId>
			<version>5.0.6.RELEASE</version>
		</dependency>
```

스프링 시큐리티와 관련된 정보를 출력하거나 사용하려면 JSP 상단에 스프링 시큐리티 관련 태그 라이브러리의 사용을 선언하고, <sec:authentication> 태그와
principal 이라는 이름의 속성을 사용한다.
```jsp
	<p>principal : <sec:authentication property="principal" /></p>
	<p>MemberVO : <sec:authentication property="principal.member" /></p>
	<p>사용자 이름 : <sec:authentication property="principal.member.userName" /></p>
	<p>사용자 아이디 : <sec:authentication property="principal.username" /></p>
	<p>사용자 권한 리스트 : <sec:authentication property="principal.member.authList" /></p>
```
<sec:authentication property="principal" />를 이용했을 때 의미하는 것은 UserDetailsService에서 반환된 객체이다.
즉 CustomUserDetailsService를 이용했다면 loadUserByUsername()에서 반환된 CustomUser 객체가 된다.
이 사실을 이해하면 'principal'이 CustomUser를 의미하므로 적절하게 호출할 수 있다.

% 표현식을 이용하는 동적 화면 구성!
사용자의 권한에 따라 화면을 다르게 보여줄 필요가 있을 때가 있다. 이때 유용한 것이 스프링 시큐리티의 표현식이다. 표현식은 security-context.xml 에서 이미 사용하고있다.
### 표현식
 - hasRole([role]) / hasAuthority([authority]) : 해당 권한이 있으면 true
 - hasAnyRole([role, role2]) / hasAnyAuthority([authority]) : 여러 권한들 중 하나라도 해당한다면 true
 - principal : 현재 사용자 정보를 의미
 - permitAll : 모든 사용자에게 허용
 - denyAll : 모든 사용자에게 거부
 - isAnonymous() : 익명 사용자의 경우(로그인 하지 않은 경우도 해당)
 - isAuthenticated() : 인증된 사용자면 true
 - isFullyAuthenticated() : Remember-me로 인증된 것이 아닌 인증된 사용자인 경우 true
 
```jsp
<sec:authorize access="isAnonymous()">
		<a href="/customLogin">로그인</a>
	</sec:authorize>
	
	<sec:authorize access="isAuthenticated()">
		<a href="/customLogout">로그아웃</a>
	</sec:authorize>
```





# 자동 로그인(remember-me)
이 기능은 거의 쿠키(Cookie)를 이용해서 구현 된다. 스프링 시큐리티의 경우 `remember-me`기능을 메모리상에서 처리하거나 DB를 이용하는 형태로 약간의 설정만으로 구현이 가능하다.
security-context.xml에서 <security:remember-me> 태그를 이용해서 기능을 구현한다.
### <security:remember-me>의 속성
 - key : 쿠키에 사용되는 값을 암호화하기 위한 key값
 - data-source-ref: DataSource를 지정하고 테이블을 이용해서 기존 로그인 정보를 기록(옵션)
 - remember-me-cookie: 브라우저에 보관되는 쿠키의 이름을 지정한다. 기본 값은 `remember-me`
 - remember-me-parameter: 웹 화면에서 로그인할 때 `remember-me`는 대부분 체크박스를 이용해서 처리한다. 이때 체크박스 태그는 name 속성을 의미한다.
 - token-validity-seconds: 쿠키의 유효시간을 지정한다.
 
% DB를 이용하는 자동 로그인
자동 로그인 기능을 가장 많이 사용되는 방식은 로그인이 되었던 정보를 DB를 이용해서 기록해 두었다가 사용자의 재방문 시 세션에 정보가 없으면 DB를 조회해서 사용하는 방식이다.
서버의 메모리상에만 데이터를 저장하는 방식보다 좋은 점은 DB에 정보가 공유되기 때문에 좀 더 안정적으로 운영이 가능하다.
`remember-me` 기능은 지정된 이름의 테이블을 생성하면 지정된 SQL문이 실행되면서 이를 처리하는 방식과 직접 구현하는 방식이 있다.
생성된 테이블은 로그인을 유지하는데 필요한 정보를 보관하는 용도일 뿐이므로, 커스터마이징 하기 보다는 지정된 형식의 테이블을 생성한다.
 
```sql
create table persistent_logins (
  username varchar(64) not null,
  series varchar(64) primary key,
  token varchar(64) not null,
  last_used timestamp not null
);
``` 

자동 로그인에서 DB를 이용하는 설정은 별도의 설정 없이 data-source-ref만을 지정하면 된다.
security-context.xml의 일부
```xml
<security:http>
	<security:remember-me data-source-ref="dataSource" token-validity-seconds="604800" />
</security:http>
```

```jsp
<div>
			<input type="checkbox" name="remember-me">Remember Me
		</div>
```

프로젝트를 실행하고 자동 로그인 체크 후 브라주저 쿠키를 조사하면 `remember-me`라는 이름의 쿠키가 생긴 것을 확인할 수 있다. 또한 DB에도 정보가 추가 됐다.

% 로그아웃 시 쿠키 삭제
자동 로그인에 사용하는 쿠키도 삭제해 주도록 쿠키를 삭제한느 항목을 security-context.xml에 지정한다.
```xml
<security:logout logout-url="/customLogout" invalidate-session="true" delete-cookies="remember-me,JSESSION_ID"/>
```

별도의 설정이 없다면 자동 로그인에서 사용한 쿠키의 이름은 remember-me 일 것이고, Tomcat을 통해서 실행되고 있었다면 WAS가 발행하는 쿠키의 이름은 JSESSION_ID 이다.
Tomcat 등이 발행하는 쿠키는 굳이 지정할 필요가 없지만 관련된 모든 쿠키를 같이 삭제하도록 해 주는 것이 좋다.








# 어노테이션을 이용하는 스프링 시큐리티 설정
XML 이나 Java 설정을 이용해서 스프링 시큐리티를 설정하고 사용하는 방식도 좋지만 매번 필요한 URL에 따라서 설정을 변경하는 일은 번거롭다.
스프링 시큐리티는 어노테이션을 이용해서 필요한 설정을 추가할 수 있다. 사용되는 어노테이션은 주로 세 가지가 있다.
	* @Secured : 스프링 시큐리티 초기부터 사용되었고, () 안에 `ROLE_ADMIN`과 같은 문자열 혹은 문자열 배열을 이용한다.
	* @PreAuthorize, @PostAuthorize : 3버전부터 지원되며, () 안에 표현식을 사용할 수 있으므로 최근에는 더 많이 사용된다.
	
```class
	// Security Annotation 사용
	@PreAuthorize("hasAnyRole('ROLE_ADMIN', 'ROLE_MEMBER')")
	@GetMapping("/annoMember")
	public void doMember2() {
		log.info("logined annotation member");
	}
	
	
	@Secured({"ROLE_ADMIN"})
	@GetMapping("/annoAdmin")
	public void doAdmin2() {
		log.info("admin annotation only");
	}
```

@Secured에는 단순히 값만을 추가할 수 있으므로 여러 개를 사용할 때에는 배열로 표현한다.
주의할 사항은 컨트롤러에 사용하는 스프링 시큐리티의 어노테이션을 활성화하기 위해서는 스프링 MVC의 설정을 담당하는 servlet-context.xml에 관련 설정이 추가되어야 한다.
따라서 servlet-context.xml에 namespace 탭에 security를 추가한다. 추가하면 자동으로 xml 소스에
xsi:schemaLocation="http://www.springframework.org/schema/security http://www.springframework.org/schema/security/spring-security-5.0.xsd
가 생기는데 5.0 버전으로 추가되는 것은 에러가 발생하기 때문에 4.2 버전으로 낮추거나 버전을 지워야 정상 작동한다.
시큐리티를 체크 했으면 시큐리티를 이용해  코드를 추가 한다.
```xml
<security:global-method-security pre-post-annotations="enabled" secured-annotations="enabled" />
```
어노테이션은 default로 `disabled`되어 있으므로 `enabled`로 설정한다.


 





