---
title: "OIDC(OpenID Connect) 简介"
date: 2022-07-06T08:47:49+08:00
menu:
  sidebar:
    name: "OIDC(OpenID Connect) 简介"
    identifier: oidc-openid-connect
    weight: 10
tags: ["URL", "OIDC", "Authentication", "Authorization", "OAuth"]
categories: ["URL", "OIDC", "Authentication", "Authorization", "OAuth"]
---

- [OIDC(OpenID Connect) 简介](https://jiajunhuang.com/articles/2022_07_06-openid_connect.md.html)

### Authentication vs. authorization

> Authentication 通常是指校验是否是用户本人的这个过程，而 Authorization 则更多的是指用户是否有权限。通常我们都是先校验 是否是用户本人，然后再校验用户是否有权限。也就是先开始 Authentication，再开始 Authorization。

| Authentication                                                                                                                     | Authorization                                                                                                                     |
| ---------------------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------- |
| Determines whether users are who they claim to be                                                                                  | Determines what users can and cannot access                                                                                       |
| Challenges the user to validate credentials (for example, through passwords, answers to security questions, or facial recognition) | Verifies whether access is allowed through policies and rules                                                                     |
| Usually done before authorization                                                                                                  | Usually done after successful authentication                                                                                      |
| Generally, transmits info through an ID Token                                                                                      | Generally, transmits info through an Access Token                                                                                 |
| Generally governed by the OpenID Connect (OIDC) protocol                                                                           | Generally governed by the OAuth 2.0 framework                                                                                     |
| Example: Employees in a company are required to authenticate through the network before accessing their company email              | Example: After an employee successfully authenticates, the system determines what information the employees are allowed to access |

### OAuth 2

#### [Client Credentials Grant](https://datatracker.ietf.org/doc/html/rfc6749#section-4.4)

> 这种模式是最简单的，其实就是客户端告诉服务端自己是哪个客户端，服务器就将 access_token 下发
>
> 这种模式很少用，主要用于客户端非常可靠的情况，例如登录托管的云桌面系统，系统向服务器请求 token，服务器立刻下发，之后 用户就以云桌面特定用户的身份进行使用。

```
     +---------+                                  +---------------+
     |         |                                  |               |
     |         |>--(A)- Client Authentication --->| Authorization |
     | Client  |                                  |     Server    |
     |         |<--(B)---- Access Token ---------<|               |
     |         |                                  |               |
     +---------+                                  +---------------+

                     Figure 6: Client Credentials Flow

   The flow illustrated in Figure 6 includes the following steps:

   (A)  The client authenticates with the authorization server and
        requests an access token from the token endpoint.

   (B)  The authorization server authenticates the client, and if valid,
        issues an access token.
```

#### [Resource Owner Password Credentials Grant](https://datatracker.ietf.org/doc/html/rfc6749#section-4.3)

> 用户名密码模式，这种流程相对来说，比较适用于可信任的客户端，例如自家研发的客户端，客户端要求用户输入用户名和密码，之后 向服务器请求，服务区校验用户名密码之后，下发 access_token

```
     +----------+
     | Resource |
     |  Owner   |
     |          |
     +----------+
          v
          |    Resource Owner
         (A) Password Credentials
          |
          v
     +---------+                                  +---------------+
     |         |>--(B)---- Resource Owner ------->|               |
     |         |         Password Credentials     | Authorization |
     | Client  |                                  |     Server    |
     |         |<--(C)---- Access Token ---------<|               |
     |         |    (w/ Optional Refresh Token)   |               |
     +---------+                                  +---------------+

            Figure 5: Resource Owner Password Credentials Flow

   The flow illustrated in Figure 5 includes the following steps:

   (A)  The resource owner provides the client with its username and
        password.

   (B)  The client requests an access token from the authorization
        server's token endpoint by including the credentials received
        from the resource owner.  When making the request, the client
        authenticates with the authorization server.

   (C)  The authorization server authenticates the client and validates
        the resource owner credentials, and if valid, issues an access
        token.
```

#### [Implicit Grant](https://datatracker.ietf.org/doc/html/rfc6749#section-4.2)

> Implicit Grant 模式，适用于不方便暴露 client_secret 的地方，比如浏览器端（网页），分发出去的 App，都属于容易被逆向的程序， 这种情况就可以使用 Implicit Grant
>
> 以最开始我们的例子，Slack 弹出 webview，加载 Google 的授权页面，Google 显示选择对应帐号，下面会提示会让客户端读取 用户信息，当用户点击确认之后，Google 校验完毕，会将页面重定向到客户端指定的地址，并且在 URL fragment 中带上 access_token。

```
     +----------+
     | Resource |
     |  Owner   |
     |          |
     +----------+
          ^
          |
         (B)
     +----|-----+          Client Identifier     +---------------+
     |         -+----(A)-- & Redirection URI --->|               |
     |  User-   |                                | Authorization |
     |  Agent  -|----(B)-- User authenticates -->|     Server    |
     |          |                                |               |
     |          |<---(C)--- Redirection URI ----<|               |
     |          |          with Access Token     +---------------+
     |          |            in Fragment
     |          |                                +---------------+
     |          |----(D)--- Redirection URI ---->|   Web-Hosted  |
     |          |          without Fragment      |     Client    |
     |          |                                |    Resource   |
     |     (F)  |<---(E)------- Script ---------<|               |
     |          |                                +---------------+
     +-|--------+
       |    |
      (A)  (G) Access Token
       |    |
       ^    v
     +---------+
     |         |
     |  Client |
     |         |
     +---------+

   Note: The lines illustrating steps (A) and (B) are broken into two
   parts as they pass through the user-agent.

                       Figure 4: Implicit Grant Flow

   The flow illustrated in Figure 4 includes the following steps:

   (A)  The client initiates the flow by directing the resource owner's
        user-agent to the authorization endpoint.  The client includes
        its client identifier, requested scope, local state, and a
        redirection URI to which the authorization server will send the
        user-agent back once access is granted (or denied).

   (B)  The authorization server authenticates the resource owner (via
        the user-agent) and establishes whether the resource owner
        grants or denies the client's access request.

   (C)  Assuming the resource owner grants access, the authorization
        server redirects the user-agent back to the client using the
        redirection URI provided earlier.  The redirection URI includes
        the access token in the URI fragment.

   (D)  The user-agent follows the redirection instructions by making a
        request to the web-hosted client resource (which does not
        include the fragment per [RFC2616]).  The user-agent retains the
        fragment information locally.

   (E)  The web-hosted client resource returns a web page (typically an
        HTML document with an embedded script) capable of accessing the
        full redirection URI including the fragment retained by the
        user-agent, and extracting the access token (and other
        parameters) contained in the fragment.

   (F)  The user-agent executes the script provided by the web-hosted
        client resource locally, which extracts the access token.

   (G)  The user-agent passes the access token to the client.
```

#### [Authorization Code Grant](https://datatracker.ietf.org/doc/html/rfc6749#section-4.1)

> Authorization Code 模式，这是最复杂，也是最安全的一种授权模式
>
> 首先 Slack 客户端打开 webview，加载 Google 的授权页面，并且指定模式为 Authorization Code，Google 让用户确认之后，重定向 回 Slack 指定的 URL，并且在参数中附带一个参数，叫做 code，随后 Slack 的服务端拿着 code，带上 client_id, client_secret 再次请求 Google，此时 Google 校验 token，如成功，则下发 access_token。由于是 Slack 的服务器直接请求获得的 token，因此会 比前面三种都更加安全。

```
     +----------+
     | Resource |
     |   Owner  |
     |          |
     +----------+
          ^
          |
         (B)
     +----|-----+          Client Identifier      +---------------+
     |         -+----(A)-- & Redirection URI ---->|               |
     |  User-   |                                 | Authorization |
     |  Agent  -+----(B)-- User authenticates --->|     Server    |
     |          |                                 |               |
     |         -+----(C)-- Authorization Code ---<|               |
     +-|----|---+                                 +---------------+
       |    |                                         ^      v
      (A)  (C)                                        |      |
       |    |                                         |      |
       ^    v                                         |      |
     +---------+                                      |      |
     |         |>---(D)-- Authorization Code ---------'      |
     |  Client |          & Redirection URI                  |
     |         |                                             |
     |         |<---(E)----- Access Token -------------------'
     +---------+       (w/ Optional Refresh Token)

   Note: The lines illustrating steps (A), (B), and (C) are broken into
   two parts as they pass through the user-agent.

                     Figure 3: Authorization Code Flow

   The flow illustrated in Figure 3 includes the following steps:

   (A)  The client initiates the flow by directing the resource owner's
        user-agent to the authorization endpoint.  The client includes
        its client identifier, requested scope, local state, and a
        redirection URI to which the authorization server will send the
        user-agent back once access is granted (or denied).

   (B)  The authorization server authenticates the resource owner (via
        the user-agent) and establishes whether the resource owner
        grants or denies the client's access request.

   (C)  Assuming the resource owner grants access, the authorization
        server redirects the user-agent back to the client using the
        redirection URI provided earlier (in the request or during
        client registration).  The redirection URI includes an
        authorization code and any local state provided by the client
        earlier.

   (D)  The client requests an access token from the authorization
        server's token endpoint by including the authorization code
        received in the previous step.  When making the request, the
        client authenticates with the authorization server.  The client
        includes the redirection URI used to obtain the authorization
        code for verification.

   (E)  The authorization server authenticates the client, validates the
        authorization code, and ensures that the redirection URI
        received matches the URI used to redirect the client in
        step (C).  If valid, the authorization server responds back with
        an access token and, optionally, a refresh token.
```

#### [Authorization Code PKCE 扩展](https://datatracker.ietf.org/doc/html/rfc7636)

> 这个模式，和 Authorization Code 基本相同，不同的地方在于不暴露 client_secret，因此可以用于浏览器等。流程如下：
>
> > 首先浏览器生成随机字符串，我们称之为 code_verifier，长度限制在 43-128 字符
> > 随后，我们将 code_verifier 做 sha256 加密，然后做 URL safe base64 encode，得到的字符我们称为 code_challenge
> > 接着，客户端打开授权服务器的页面，并且在参数中附带 code_challenge=巴拉巴拉巴拉&code_challenge_method=S256， code_challenge 是第二步中生成的，code_challenge_method 指定哈希方法，S256 指的是 sha256，授权服务器将这些信息记录下来
> > 随后服务器提示用户是否授权，当用户授权之后，服务器回调浏览器指定的 URL，并且带上 code
> > 客户端将 code 提取出来，然后请求授权服务器，并且带上 code 和 code_verifier
> > 授权服务器提取请求中的 code_verifier，将其做 sha256，并且与第三步中的 code_challenge 进行对比，如果一致，则说明授权 成功，于是下发 access_token

### JWT

`eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyfQ.SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c`
其实就是三部分：

- Header，指示 token 类型和签名算法
- Payload，包含了真正有用的信息，通常也叫做 claims
- Signature，这是 Header 和 Payload 进行签名之后的结果

### OpenID Connect(OIDC)

> OIDC 主要的目的在于登录用户，获取用户信息，而不是获取其它权限。前面我们说了，OIDC 基于 OAuth 2， 因此，OIDC 可以使用 Authorization Code 模式，也可以使用 Implicit 模式，还有一种 Hybrid 模式。
>
> 通过 OIDC，我们可以以第三方系统的身份来登录另外一个系统，并且获取一些基本的资料，例如 first name, last name, username, email, avatar url 等。

#### [Authentication using the Authorization Code Flow](https://openid.net/specs/openid-connect-core-1_0.html#CodeFlowAuth)

The Authorization Code Flow goes through the following steps:

- Client prepares an Authentication Request containing the desired request parameters.
- Client sends the request to the Authorization Server.
- Authorization Server Authenticates the End-User.
- Authorization Server obtains End-User Consent/Authorization.
- Authorization Server sends the End-User back to the Client with an Authorization Code.
- Client requests a response using the Authorization Code at the Token Endpoint.
- Client receives a response that contains an ID Token and Access Token in the response body.
- Client validates the ID token and retrieves the End-User's Subject Identifier.

基本就是 OAuth 2 Authorization Code 模式的流程，区别在于，在 scope 参数中，一定有一项叫做 openid，另外一点就在于最终 的返回结果里，多了一项 id_token

```json
{
    "access_token": "SlAV32hkKG",
    "token_type": "Bearer",
    "refresh_token": "8xLOxBtZp8",
    "expires_in": 3600,
    "id_token": "eyJhbGciOiJSUzI1NiIsImtpZCI6IjFlOWdkazcifQ.ewogImlzc
        yI6ICJodHRwOi8vc2VydmVyLmV4YW1wbGUuY29tIiwKICJzdWIiOiAiMjQ4Mjg5
        NzYxMDAxIiwKICJhdWQiOiAiczZCaGRSa3F0MyIsCiAibm9uY2UiOiAibi0wUzZ
        fV3pBMk1qIiwKICJleHAiOiAxMzExMjgxOTcwLAogImlhdCI6IDEzMTEyODA5Nz
        AKfQ.ggW8hZ1EuVLuxNuuIJKX_V8a_OMXzR0EHR9R6jgdqrOOF4daGU96Sr_P6q
        Jp6IcmD3HP99Obi1PRs-cwh3LO-p146waJ8IhehcwL7F09JdijmBqkvPeB2T9CJ
        NqeGpe-gccMg4vfKjkM8FcGvnzZUN4_KSP0aAp1tOJ1zZwgjxqGByKHiOtX7Tpd
        QyHE5lcMiKPXfEIQILVq0pc_E2DzL7emopWoaoZTF_m0_N0YzFC6g6EJbOEoRoS
        K5hoDalrcvRYLSrQAZZKflyuVCyixEoV9GfNQC3_osjzw2PAithfubEEBLuVVk4
        XUVrWOLrLl0nx7RkKU8NXNHq-rvKMzqg"
}
```

id_token

```json
{
	"iss": "http://server.example.com",
	"sub": "248289761001",
	"aud": "s6BhdRkqt3",
	"nonce": "n-0S6_WzA2Mj",
	"exp": 1311281970,
	"iat": 1311280970
}
```

- iss 是 Issuer 的缩写，值是颁发这个 OpenID 的 URL
- sub 是 Subject 的缩写，指的是这个 OpenID 对应的用户
- aud 是 Audience(s) 的缩写，指的是这个 OpenID 所授权的 client id(可能有多个)
- exp 是 超时时间
- iat 是 颁发时间
- nonce 是随机字符串

#### [Authentication using the Implicit Flow](https://openid.net/specs/openid-connect-core-1_0.html#ImplicitFlowAuth)

步骤如下：

- Client prepares an Authentication Request containing the desired request parameters.
- Client sends the request to the Authorization Server.
- Authorization Server Authenticates the End-User.
- Authorization Server obtains End-User Consent/Authorization.
- Authorization Server sends the End-User back to the Client with an ID Token and, if requested, an Access Token.
- Client validates the ID token and retrieves the End-User's Subject Identifier.

流程也基本和 OAuth 2 的 Implicit 模式一致，区别在于 response_type 的值不是 token，而是 id_token token 或者 id_token， 对于响应结果，也是会新增加一个 id_token 在 URL fragment 里。

#### [Authentication using the Hybrid Flow](https://openid.net/specs/openid-connect-core-1_0.html#HybridFlowAuth)

步骤如下：

- Client prepares an Authentication Request containing the desired request parameters.
- Client sends the request to the Authorization Server.
- Authorization Server Authenticates the End-User.
- Authorization Server obtains End-User Consent/Authorization.
- Authorization Server sends the End-User back to the Client with an Authorization Code and, depending on the Response Type, one or more additional parameters.
- Client requests a response using the Authorization Code at the Token Endpoint.
- Client receives a response that contains an ID Token and Access Token in the response body.
- Client validates the ID Token and retrieves the End-User's Subject Identifier.

区别在于，请求参数中，response_type 的值是 code id_token 或 code token 或 code id_token token：

- 当值是 code token 时，会返回 code, access_token
- 当值是 code id_token 时，会返回 code, id_token
- 当值是 code id_token token 时，会返回 code, id_token, access_token
