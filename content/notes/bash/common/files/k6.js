import http from 'k6/http';

// 默认控制选项
export let options = {
  vus: 10,         // 指定要同时运行的虚拟用户（VUs）数
	duration: '1s', // 指定测试运行的总持续时间
	noVUConnectionReuse: true, // 是否复用 TCP 链接
	rps: 500, // 每秒发出的最大请求数
	userAgent: 'Mozilla/5.0',
	tlsVersion: { // 表示允许在与服务器交互中使用的唯一 SSL/TLS 版本的字符串，或者一个指定允许使用的“最小”和“最大”版本的对象
    min: 'tls1.2',
    max: 'tls1.3',
	},
	tlsCipherSuites: [ // 允许在与服务器的 SSL/TLS 交互中使用的密码套件列表。由于底层 go 实现的限制，不支持更改 TLS 1.3 的密码，并且不会执行任何操作
    'TLS_RSA_WITH_RC4_128_SHA',
    'TLS_RSA_WITH_AES_128_GCM_SHA256',
	],
	// tlsAuth: [ // tls 身份验证
  //   {
  //     domains: ['example.com'],
  //     cert: open('mycert.pem'),
  //     key: open('mycert-key.pem'),
	// 	},
	// ],
	throw: true, // 在失败的 HTTP 请求上抛出异常
	thresholds: { // 一组阈值规范，用于根据指标数据配置在何种条件下测试成功与否，测试通过或失败
		// 发出的请求数量需要大于1000
    http_reqs:['count>1000'],
    // 错误率应该效率 0.01%
    http_req_failed: ['rate<0.01'],
    // 返回的内容必须小于 4000 字节。
    ContentSize: ['value<4000'],
    // p(N) 其中 N 是一个介于 0.0 和 100.0 之间的数字，表示要查看的百分位值，例如p(99.99) 表示第 99.99 个百分位数。这些值的单位是毫秒。
    // 90% 的请求必须在 400 毫秒内完成，95% 必须在 800 毫秒内完成，99.9% 必须在 2 秒内完成
    http_req_duration: ['p(90) < 400', 'p(95) < 800', 'p(99.9) < 2000'],
    // 99% 响应时间必须低于 300 毫秒，70% 响应时间必须低于 250 毫秒，
    // 平均响应时间必须低于 200 毫秒，中位响应时间必须低于 150 毫秒,最小响应时间必须低于 100 毫秒
    RTT: ['p(99)<300', 'p(70)<250', 'avg<200', 'med<150', 'min<100'],
	},
	noCookiesReset: true, // 重置 Cookies，fasle 每次迭代都会重置 Cookie ，true 会在迭代中持久化 Cookie
	noConnectionReuse: true, // 禁用保持活动连接
	batchPerHost: 50, // 每个主机的批量请求数
	blacklistIPs: ['10.0.0.0/8'], // 黑名单
	blockHostnames: ["test.k6.io", "*.example.com"], // 基于模式匹配字符串来阻止主机
	discardResponseBodies: true, // 是否应丢弃响应正文，将 responseType 的默认值修改成 none，建议设置成 true，可以减少内存暂用和 GC 使用，有效的较少测试机的负载
	httpDebug: 'full', // 记录所有 HTTP 请求和响应。默认情况下排除正文，包括正文使用 –http debug=full
};

// default 默认函数
export default function () {
	let json = { content: 'linhui', image: 'images' };
  // 标头
  let params = { headers: { 'Content-Type': 'application/json' } };
  var res = http.post("https://dev-testing.example.com", JSON.stringify(json), params)
}