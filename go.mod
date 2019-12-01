module project.localhost/example

replace project.localhost/purescript-native/ffi-loader => /Users/mark/code/psgotest/purescript-native

replace project.localhost/purescript-native/output => /Users/mark/code/psgotest/output

replace project.localhost/i-am-the-slime/purescript-goroutine => /Users/mark/code/psgotest/purescript-goroutine

replace project.localhost/i-am-the-slime/purescript-go-elasticsearch => /Users/mark/code/psgotest/purescript-go-elasticsearch

require (
	github.com/elastic/go-elasticsearch/v8 v8.0.0-20191106142240-0b113bc5565f
	github.com/purescript-native/go-ffi v0.0.0-20191015034244-22b13919279c // indirect
	github.com/purescript-native/go-runtime v0.0.0-20190907045917-ec626efcf4a1 // indirect
	project.localhost/i-am-the-slime/purescript-go-elasticsearch v0.0.0-00010101000000-000000000000 // indirect
	project.localhost/i-am-the-slime/purescript-goroutine v0.0.0-00010101000000-000000000000 // indirect
	project.localhost/purescript-native/ffi-loader v0.0.0-00010101000000-000000000000 // indirect
	project.localhost/purescript-native/output v0.0.0-00010101000000-000000000000 // indirect
)
