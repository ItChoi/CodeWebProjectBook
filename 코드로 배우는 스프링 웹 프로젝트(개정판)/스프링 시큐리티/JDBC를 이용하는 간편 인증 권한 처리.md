### JDBC를 이용하는 간편 인증/권한 처리
 - 스프링 시큐리티에서는 사용자를 확인하는 '인증(Authentication)'과 권한 등을 부여하는 '인가 과정(Authorization)'으로 나누어 볼 수 있다. 인증과 권한에 대한 처리는 크게 보면 Authentication Manager를 통해서 이루어지는데 이때 인증이나 권한 정보를 제공하는 존재(Provider)가 필요하고, 다시 이를 위해서 UserDetailsService라는 인터페이스를 구현한 존재를 활용하게 된다.

UserDetailsService는 스프링 시큐리티 API 내에 이미 CachingUserDetailsService, InMemoryUserDetailsManager, JdbcDaoImpl, JdbcUserDetailsManager, LdapUserDetailsManager, LdapUserDetailsService와 같은 구현 클래스들을 제공하고 있다. 이전 security-context.xml에 문자열로 고정한 방식은 사실 InMemoryUserDetailsmanager를 이용한 것이다.

% spring security 설정 <security:jdbc-user-service data-source-ref="dataSource" />는 기본적으로 DataSource가 필요하므로 root-context.xml에 dataSource 설정을 추가한다.



% JDBC를 이용하기 위한 테이블 설정
JDBC를 이용해서 인증/권한을 체크하는 방식은 크게 1) 지정된 형식으로 테이블을 생성해서 사용하는 방식과 2) 기존에 작성된 데이터베이스를 이용하는 방식이 있다.

스프링 시큐리티가 JDBC를 이용하는 경우에 사용하는 클래스는 JdbcUserDetailsManager 클래스 인데 github 등에 공개된 코드를 보면 아래와 같은 SQL(쓰기 귀찮) 등이 이용되는 것을 확인할 수 있다.(https://github.com/spring-projects/spring-security/blob/master/core/src/main/java/org/springframework/security/provisioning/JdbcUserDetailsManager.java).


만일 스프링 시큐리티에서 지정된 SQL을 그대로 이용하고 싶다면 지정된 형식으로 테이블을 생성해 주기만 하면 된다.
ex)
create table users(
    username varchar2(50) not null primary key,
    password varchar2(50) not null,
    enabled char(1) default '1'
);

create table authorities (
    username varchar2(50) not null,
    authority varchar2(50) not null,
    constraint fk_authorities_users foreign key(username) references users(username)
);

create unique index ix_auth_username on authorities (username, authority);


insert into users (username, password) values ('user00', 'pw00');
insert into users (username, password) values ('member00', 'pw00');
insert into users (username, password) values ('admin00', 'pw00');

insert into authorities (username, authority) values ('user00', 'ROLE_USER');
insert into authorities (username, authority) values ('member00', 'ROLE_MANAGER');
insert into authorities (username, authority) values ('admin00', 'ROLE_USER');
insert into authorities (username, authority) values ('user00', 'ROLE_ADMIN');

commit;




그리고 security-context.xml의 <security:authentication-manager> 내용은 아래와 같이 작성한다.
```xml
<security:authentication-manager>
		<security:authentication-provider>
			<security:jdbc-user-service data-source-ref="dataSource"/>
			<!-- <security:user-service>
				<security:user name="member" password="{noop}member" authorities="ROLE_MEMBER"/>
				<security:user name="admin" password="{noop}admin" authorities="ROLE_ADMIN"/>
			</security:user-service> -->
		</security:authentication-provider>
	</security:authentication-manager>
```

WAS를 실행해서 인증/권한이 필요한 URI를 호출해 보면 별도의 처리 없이 자동으로 필요한 쿼리들이 호출되는 것을 확인할 수 있다. (? 난 왜 안뜨지? 로그 설정 떄문? 그러나 정상동작 같다.)

스프링 시큐리티 5부터는 기본적으로 PasswordEncoder를 지정해야만 한다. 임시로 '{nope}' 접두어를 이용할 수 있지만, DB 등을 이용하는 경우 PasswordEncoder를 이용해야 한다.
문제는 패스워드 인코딩을 처리하고 나면 사용자 계정을 입력할 때 인코딩 작업이 추가되어야 하기 때문에 할 일이 많아진다.

PasswordEncoder는 인터페이스로 설계되어 있고, 이미 여러 종류의 구현 클래스들이 존재한다.
스프링 4버전까지는 PasswordEncoder를 사용하지 않고 NoOpPasswordEncoder를 이용해서 처리할 수 있었지만, 5버전부터는 Deprecated되어 사용할 수 없다.
직접 암호화가 없는 PasswordEncoder를 구현해서 사용해보자.

```java
@Log4j
public class CustomNoOpPasswordEncoder implements PasswordEncoder {

	@Override
	public String encode(CharSequence rawPassword) {
		
		log.warn("before encode: " + rawPassword);
		
		return rawPassword.toString();
	}

	@Override
	public boolean matches(CharSequence rawPassword, String encodedPassword) {
		
		log.warn("matches: " + rawPassword + " : " + encodedPassword);
		
		return rawPassword.toString().equals(encodedPassword);
	}

}
```

위 클래스를 security-context.xml에서 빈으로 등록한다
```xml
<bean id="customPasswordEncoder" class="org.zerock.security.CustomNoOpPasswordEncoder"></bean>

<security:authentication-manager>
		<security:authentication-provider>
			<security:jdbc-user-service data-source-ref="dataSource"/>
			<security:password-encoder ref="customPasswordEncoder" />
			<!-- <security:user-service>
				<security:user name="member" password="{noop}member" authorities="ROLE_MEMBER"/>
				<security:user name="admin" password="{noop}admin" authorities="ROLE_ADMIN"/>
			</security:user-service> -->
		</security:authentication-provider>
	</security:authentication-manager>
```

WAS를 실행해서 로그인 후 JDBC를 이용한 처리가 제대로 되었는지 확인하기.


% 위 내용들은 스프링 시큐리티에 지정된 형식으로 테이블을 생성해서 사용하는 방식이다. 이제는 기존의 테이블을 이용하는 경우를 알아보자.
기존의 회원 관련 데이트베이스가 구축되어 있었다면 테이블 설계에 맞게 시큐리티를 적용할  필요가 있다.

테이블 설계
create table tbl_member(
    userid varchar2(50) not null primary key,
    userpw varchar2(100) not null,
    username varchar2(100) not null,
    regdate date default sysdate,
    updatedate date default sysdate,
    enabled char(1) default '1'
);

create table tbl_member_auth (
    userid varchar2(50) not null,
    auth varchar2(50) not null,
    constraint fk_member_auth foreign key(userid) references tbl_member(userid)
);


% BCryptPasswordEncoder 클래스를 이용한 패스워드 보호
스프링 시큐리티에서 제공되는 BCryptPasswordEncoder 클래스를 이용해서 패스워드를 암호화해서 처리하도록 할 수 있다. bcrypt는 태생 자체가 패스워드를 저장하는 용도로
설계된 해시 함수로 특정 문자열을 암호화하고, 체크하는 쪽에서는 암호화된 패스워드가 가능한 패스워드인지만 확인하고 다시 원문으로 되돌리지는 못한다.

BcryptPasswordEncoder는 이미 스프링 시큐리티의 API 안에 포함되어 있으므로, 이를 활용해서 security-context.xml에 설정 한다.
```xml
<bean id="bcryptPasswordEncoder" class="org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder"></bean>

<security:password-encoder ref="bcryptPasswordEncoder" />
```

실제로 DB에 기록하는 회원 정보는 BcryptPasswordEncoder를 이용해서 암호화된 상태로 넣어주어야 하므로 테스트 코드를 작성해보자!
테스트 코드 실행을 위해 pom.xml에 spring-test를 추가해주어야 한다.
```xml
<dependency>
	<groupId>org.springframework</groupId>
	<artifactId>spring-test</artifactId>
	<version>${org.springframework-version}</version>
</dependency>
```

그리고 Test 클래스를 생성해보자~
```class
@RunWith(SpringJUnit4ClassRunner.class)
@ContextConfiguration({
	"file:src/main/webapp/WEB-INF/spring/root-context.xml",
	"file:src/main/webapp/WEB-INF/spring/security-context.xml"
})
@Log4j
public class MemberTests {
	
	@Setter(onMethod_ = @Autowired)
	private PasswordEncoder pwEncoder;
	
	@Setter(onMethod_ = @Autowired)
	private DataSource ds;
	
	
	@Test
	public void testInsertMember() {
		String sql = "insert into tbl_member(userid, userpw, username) values (?,?,?)";
		
		Connection con = null;
		PreparedStatement pstmt = null;
		
		for (int i = 0; i < 100; i++) {
			
			try {
				con = ds.getConnection();
				pstmt = con.prepareStatement(sql);
				
				pstmt.setString(2, pwEncoder.encode("pw" + i));
				
				if (i < 80) {
					pstmt.setString(1, "user" + i);
					pstmt.setString(3, "일반사용자" + i);
				} else if (i < 90) {
					pstmt.setString(1, "manager" + i);
					pstmt.setString(3, "운영자" + i);
				} else {
					pstmt.setString(1, "admin" + i);
					pstmt.setString(3, "관리자" + i);
				}
				
				pstmt.executeUpdate();
				
			} catch(Exception e) {
				e.printStackTrace();
			} finally {
				try {
					if (pstmt != null) {
						pstmt.close();
					}
					
					if(con != null) {
						con.close();
					}
				} catch (Exception e) {
					
				}
			}
			
		}
		
	}
}
```
위 테스트 클래스는 연결된 DB에 100개 만큼의 회원 정보를 insert 시킨다. (자바 for문으로 하니 역시 느리군...) - 기존에 security-context에서 사용하던 ```xml 
<!-- <bean id="customPasswordEncoder" class="org.zerock.security.CustomNoOpPasswordEncoder"></bean> -->``` 을 남겨두니 에러가 발생해서 주석 처리 했다.

% 생성된 사용자에 권한 추가하기.
 사용자 생성이 완료되었다면 tbl_member_auth 테이블에 사용자의 권한에 대한 정보도 추가해야 한다.
```class
@Test
	public void testInsertAuth() {
		
		Connection con = null;
		PreparedStatement pstmt = null;
		
		String sql = "insert into tbl_member_auth (userid, auth) values (?,?)";

		try {
			con = ds.getConnection();
			pstmt = con.prepareStatement(sql);
			
			for (int i = 0; i < 100; i++) {
				if (i < 80) {
					pstmt.setString(1, "user"+i);
					pstmt.setString(2, "ROLE_USER");
				} else if (i < 90) {
					pstmt.setString(1, "manager"+i);
					pstmt.setString(2, "ROLE_MEMBER");
				} else {
					pstmt.setString(1, "admin"+i);
					pstmt.setString(2, "ROLE_ADMIN");
				}
				
				pstmt.executeUpdate();
				
			}
			
		} catch (Exception e) {
			e.printStackTrace();
		} finally {
			try {
				if (pstmt != null) {
					pstmt.close();
				}
				if (con != null) {
					con.close();
				}
			} catch (Exception e) {
				e.printStackTrace();
			}
		}
		
	}
```

% 쿼리를 이용하는 인증
기존 테이블 형식에 맞게 인증과 권한을 처리할 경우 인증 쿼리(users-by-username-query)와 권한 확인 쿼리(authorities-by-username-query)를 이용해서 처리해야 한다.

security-context.xml의 일부
```xml
<security:jdbc-user-service 
				data-source-ref="dataSource" 
				users-by-username-query="select userid, userpw, enabled from tbl_member where userid = ?"
				authorities-by-username-query="select userid, auth from tbl_member_auth where userid = ?" />
```
입력한 내용으로 인증과 권한을 체크하여 로그인 접속이 성공한다. 
-> ? jsp에서 username과 password로 입력한 값들이 쿼리 상에 userid에 자동으로 대입되어 들어간다. name 매치가 안되는데도 들어가네 




