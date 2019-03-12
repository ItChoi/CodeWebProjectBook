### 커스텀 UserDetailsService 활용
JDBC를 이용하는 방식으로도 DB를 처리해서 편리하게 사용할 수 잇기는 하지만, 사용자의 여러 정보들 중에서 제한적인 내용만을 이용한다는 단점이 있다. 
스프링 시큐리티에서 username 사용자 정보만을 이용하기 때문에 실제 프로젝트에서 상ㅇ자의 이름이나 이메일 등의 자세한 정보를 이용할 경우에는 충분하지 못하다는 단점이 있다.

이러한 문제를 해결하기 위해서 직접 UserDetailsService를 구현하는 방식을 사용해보자. 이를 이용하면 원하는 객체를 인증과 권한 체크에 활용할 수 있기 때문에 많이 사용하고 있다.
UserDetailsService 인터페이스는 단 하나의 메서드만이 존재한다. ex) UserDetails loadUserByUsername(java.lang.String username)
UserDetails는 사용자의 권한 정보 등을 담는 인터페이스이다. UserDetails타입은 1) getAuthorities(), 2) getPassword() 3) getUserName() 등의
여러 추상 메서드를 가지고 있어서, 개발 전에 이를 직접 구현할 것인지 UserDetails 인터페이스를 구현해둔 스프링 시큐리티의 여러 하위 클래스를 이용할 것인지 판단해야 한다.

가장 일반적으로 사용되는 방법은 여러 하위 클래스들 중에서 org.springframework.security.core.userdetails.User 클래스를 상속하는 형태이다.

 
1. 회원 도메인, 회원 Mapper 설계 (Mybatis 사용)
```class
@Data
public class MemberVO {
	private String userid;
	private String userpw;
	private String userName;
	private boolean enabled;
	
	private Date regDate;
	private Date updateDate;
	private List<AuthVO> authList;
}

@Data
public class AuthVO {
	private String userid;
	private String auth;
}

public interface MemberMapper {
	public MemberVO read(String userid);
}
```

사용자는 여러 개의 권한을 가질 수 있도록 설계한다.

```xml
<resultMap id="memberMap" type="org.zerock.domain.MemberVO">
		<id property="userid" column="userid"/>
		<result property="userid" column="userid"/>
		<result property="userpw" column="userpw"/>
		<result property="userName" column="username"/>
		<result property="regDate" column="regdate"/>
		<result property="updateDate" column="updatedate"/>
		<collection property="authList" resultMap="authMap"></collection>
	</resultMap>

	<resultMap id="authMap" type="org.zerock.domain.AuthVO">
		<result property="userid" column="userid"/>
		<result property="auth" column="auth"/>
	</resultMap>
	
	<select id="read" resultMap="memberMap">
		select
			mem.userid, userpw, username, enabled, regdate, updatedate, auth
		from 
			tbl_member mem
			left outer join tbl_member_auth auth
			on mem.userid = auth.userid
		where
			mem.userid = #{userid}
	</select>
```

% 요기까지 했으면 테스트를 안해볼 수가 없겠지?!
```class
@RunWith(SpringRunner.class)
@ContextConfiguration({
	"file:src/main/webapp/WEB-INF/spring/root-context.xml"
})
@Log4j
public class MemberMapperTests {
	@Setter(onMethod_ = @Autowired)
	private MemberMapper mapper;
	
	@Test
	public void testRead() {
		MemberVO vo = mapper.read("admin90");
		
		log.info(vo);
		
		vo.getAuthList().forEach(authVO -> log.info(authVO));
	}
}
```



% CustomUserDetailsService 구성
위에 회원을 처리하는 부분이 구성되었다면 이를 이용해서 스프링 시큐리티의 UserDetailsService를 구현하는 클래스를 직접 작성하도록 하자~
작성하려는 CustomUserDetailsService는 스프링 시큐리티의 UserDetailsService를 구현하고 MemberMapper 타입의 인스턴스를 주입받아서 실제 기능을 구현한다.

```class
@Log4j
public class CustomUserDetailsService implements UserDetailsService {

	@Setter(onMethod_ = @Autowired)
	private MemberMapper memberMapper;
	
	@Override
	public UserDetails loadUserByUsername(String userName) throws UsernameNotFoundException {
		log.warn("Load User By UserName: " + userName);
		return null;
	}

}
```

우선 스프링 시큐리티를 통해 테스트를 진행한 후 추가로 코드를 채우기로 하고, 우선은 로그만 기록해서 정상 동작하는지 확인하자~!
그러기 위해서 security-context.xml을 이용해서 빈으로 등록하자.
```xml
<bean id="customUserDetailsService" class="org.zerock.security.CustomUserDetailsService"></bean>
<security:authentication-provider user-service-ref="customUserDetailsService">
```

요기까지 하고 로그가 제대로 출려되는지 확인하자!


% MemberVO를 UsersDetails 타입으로 변환해보자~
위 코드까지 문제가 없다면 최종적으로 MemberVO의 인스턴스를 스프링 시큐리티의 UserDetails 타입으로 변환하는 작업을 처리해야 한다.
예제는 org.springframework.security.core.userdetails.User 클래스를 상속해서 CustomUser라는 클래스를 생성한다.
ex) UserDetails <- User <- CustomUser(MemberVO)

물론 MemberVO 클래스를 직접 수정해서 UserDetails 인터페이스를 구현하도록 하는 방법도 나쁘다고 생각되지는 않지만, 가능하면 기존의 클래스를
수정하지 않고 확장하는 방식이 더 낫다고 생각되기 때문에 CustomUser VO를 생성하자.
```class
@Getter
public class CustomUser extends User {

	private static final long serialVersionUID = 1L;
	private MemberVO member;
	
	public CustomUser(String username, String password, Collection<? extends GrantedAuthority> authorities) {
		super(username, password, authorities);
	}
	
	public CustomUser(MemberVO vo) {
		// 아이디, 비밀번호, 권한 list
		super(vo.getUserid(), vo.getUserpw(), vo.getAuthList()
														.stream()
														.map(auth -> new SimpleGrantedAuthority(auth.getAuth()))
														.collect(Collectors.toList()));
		
		this.member = vo;
	}
}
```

User를 상속하기 때문에 부모 클래스의 생성자를 호출해야만 정상적인 객체 생성이 가능하다.
MemberVO를 파라미터로 전달해서 User 클래스에 맞게 생성자를 호출한다. 이 과정에서 AuthVO 인스턴스는 GrantedAuthority 객체로 변환해야 하므로 stream()과 map()을 이용하여 처리

이렇게 변경 후 다시 CustomUserDetailsService에서 CustomUser를 반환하도록 수정해 보자!
```class
@Override
	public UserDetails loadUserByUsername(String userName) throws UsernameNotFoundException {
		log.warn("Load User By UserName: " + userName);
		
		// userName means userid
		MemberVO vo = memberMapper.read(userName);
		
		log.warn("queried by member mapper: " + vo);
		
		
		return vo == null ? null : new CustomUser(vo);
	}
```
이를 브라우저에서 테스트해 보면 로그인 시 CustomUserDetailsService가 동작하는 모습을 확인할 수 있다.




