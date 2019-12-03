package purescript_go_gin

import (
	"github.com/gin-gonic/gin"
	"github.com/gin-gonic/gin/binding"
	. "github.com/purescript-native/go-runtime"
)

func init() {
	exports := Foreign("Gin")

	exports["mkDefaultGin"] = func() Any {
		return gin.Default()
	}

	exports["mkHandler"] =
		func(handler_ Any) Any {
			return func(c *gin.Context) {
				Apply(handler_, c)
			}
		}

	exports["getBodyImpl"] = func(ctx_ Any) Any {
		ctx := ctx_.(*gin.Context)
		var b Dict
		ctx.ShouldBindBodyWith(&b, binding.JSON)
		return b
	}

	exports["sendJsonImpl"] =
		func(code_ Any) Any {
			return func(body_ Any) Any {
				return func(ctx_ Any) Any {
					ctx := ctx_.(*gin.Context)
					body := body_.(Dict)
					code := code_.(int)
					ctx.JSON(code, body)
					return nil
				}
			}
		}

	exports["getImpl"] = func(r_ Any) Any {
		return func(path_ Any) Any {
			return func(handler_ Any) Any {
				return func() Any {
					r := r_.(*gin.Engine)
					path := path_.(string)
					handler := handler_.(func(*gin.Context))
					r.GET(path, handler)
					return nil
				}
			}
		}
	}

	exports["postImpl"] = func(r_ Any) Any {
		return func(path_ Any) Any {
			return func(handler_ Any) Any {
				return func() Any {
					r := r_.(*gin.Engine)
					path := path_.(string)
					handler := handler_.(func(*gin.Context))
					r.POST(path, handler)
					return nil
				}
			}
		}
	}

	exports["runImpl"] = func(r_ Any) Any {
		r := r_.(*gin.Engine)
		r.Run()
		return nil
	}

}
