package purescript_goroutine

import (
	"context"
	"encoding/json"
	"log"
	"strings"

	"github.com/elastic/go-elasticsearch/v8"
	"github.com/elastic/go-elasticsearch/v8/esapi"
	. "github.com/purescript-native/go-runtime"
)

func init() {
	exports := Foreign("Elasticsearch")

	exports["mkDefaultClient"] = func() Any {
		es, _ := elasticsearch.NewDefaultClient()
		return es
	}

	exports["info"] = func(client_ Any) Any {
		return func() Any {
			client := client_.(*elasticsearch.Client)
			info, err := client.Info()
			if err != nil {
				println(err.Error())
			}
			return info
		}
	}

	exports["mkIndexRequestImpl"] = func(index_ Any) Any {
		return func(docID_ Any) Any {
			return func(body_ Any) Any {
				index := index_.(string)
				docID := docID_.(string)
				body := body_.(string)
				return esapi.IndexRequest{
					Index:      index,
					DocumentID: docID,
					Body:       strings.NewReader(body),
					// Refresh:    "true",
				}
			}
		}
	}

	exports["index"] = func(client_ Any) Any {
		return func(req_ Any) Any {
			return func() Any {
				client := client_.(*elasticsearch.Client)
				req := req_.(esapi.IndexRequest)
				res, err := req.Do(context.Background(), client)
				if err != nil {
					log.Fatalf("Error getting response: %s", err)
				}
				defer res.Body.Close()

				if res.IsError() {
					var r map[string]interface{}
					if err := json.NewDecoder(res.Body).Decode(&r); err != nil {
						log.Printf("Error parsing the response body: %s", err)
					}
					log.Printf("[%s] Error indexing document Reason=%s", res.Status(), r)

				} else {
					// Deserialize the response into a map.
					var r map[string]interface{}
					if err := json.NewDecoder(res.Body).Decode(&r); err != nil {
						log.Printf("Error parsing the response body: %s", err)
					} else {
						// Print the response status and indexed document version.
						log.Printf("[%s] %s; version=%d", res.Status(), r["result"], int(r["_version"].(float64)))
					}
				}
				return res.Status()
			}
		}

	}

}
