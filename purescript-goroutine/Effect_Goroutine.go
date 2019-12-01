package purescript_goroutine

import (
	"io/ioutil"
	"net/http"
	"sync"
	"time"

	. "github.com/purescript-native/go-runtime"
)

func init() {
	exports := Foreign("Effect.Goroutine")

	exports["httpReqImpl"] = func(left Any) Any {
		return func(right Any) Any {
			return func(url_ Any) Any {
				return func() Any {
					url := url_.(string)
					req, err := http.NewRequest(http.MethodGet, url, nil)
					if err != nil {
						return Apply(left, err.Error())
					}
					res, err := http.DefaultClient.Do(req)
					if err != nil {
						return Apply(left, err.Error())
					}
					defer res.Body.Close()
					if err != nil {
						return Apply(left, err.Error())
					}
					bodyString, err := ioutil.ReadAll(res.Body)
					if err != nil {
						return Apply(left, err.Error())
					}
					return Apply(right, (string(bodyString)))
				}
			}
		}
	}
	exports["fireAndForget"] = func(fn Any) Any {
		return func() Any {
			go Run(fn)
			return nil
		}
	}

	exports["blocking"] = func(wg_ Any) Any {
		return func(fn Any) Any {
			return func() Any {
				wg, _ := wg_.(*sync.WaitGroup)
				wg.Add(1)
				go func() {
					Run(fn)
					wg.Done()
				}()
				wg.Wait()
				return nil
			}
		}
	}

	exports["receive"] = func(channel_ Any) Any {
		return func() Any {
			channel := channel_.(chan Any)
			result := <-channel
			return result
		}
	}

	exports["go"] = func(fn Any) Any {
		return func() Any {
			go Run(fn)
			return nil
		}
	}

	exports["send"] = func(channel_ Any) Any {
		return func(value Any) Any {
			return func() Any {
				channel := channel_.(chan Any)
				channel <- value
				return nil
			}
		}
	}

	exports["sleepImpl"] = func(millis_ Any) Any {
		return func() Any {
			millis, _ := millis_.(int)
			time.Sleep(time.Duration(millis) * time.Millisecond)
			return nil
		}
	}

	exports["mkChannel"] = func() Any {
		return make(chan Any)
	}

	exports["waitGroup"] = func() Any {
		var wg sync.WaitGroup
		return &wg
	}

}
