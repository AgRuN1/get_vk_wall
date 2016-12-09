let http = require('http');
let request = require('request');
let url = require('url');
let querystring = require('querystring');

var id;

let server = http.createServer().listen(8080);

let modify = (arr) => {
    return arr.map((item)=>{
       var text = item.text.replace(/\n/g,"<br>");
       text = text.replace(/(?:(?:(?:https?|ftp|telnet):\/\/)?(?:[a-z0-9_-]{1,32}(?::[a-z0-9_-]{1,32})?@)?)?(?:(?:[a-z0-9-]{1,128}\.)+(?:ru|su|com|net|org|mil|edu|arpa|gov|biz|info|aero|inc|name|[a-z]{2})|(?!0)(?:(?!0[^.]|255)[0-9]{1,3}\.){3}(?!0|255)[0-9]{1,3})(?:\/[a-z0-9.,_@%&?+=\~/-]*)?(?:#[^ '\"&]*)?/ig,function(a,b){;return '<a href=\"'+a+'\" target=\"_blank\">'+a+'</a>'});
       
       item.text = text;
//       if(item.attachments){
//           item.attachments = item.attachments.map((attach)=>{
//              if(attach.type == 'photo'){
//                  attach.photo.text = attach.photo.text.replace(/(?:(?:(?:https?|ftp|telnet):\/\/)?(?:[a-z0-9_-]{1,32}(?::[a-z0-9_-]{1,32})?@)?)?(?:(?:[a-z0-9-]{1,128}\.)+(?:ru|su|com|net|org|mil|edu|arpa|gov|biz|info|aero|inc|name|[a-z]{2})|(?!0)(?:(?!0[^.]|255)[0-9]{1,3}\.){3}(?!0|255)[0-9]{1,3})(?:\/[a-z0-9.,_@%&?+=\~/-]*)?(?:#[^ '\"&]*)?/ig,function(a,b){;return '<a href=\"'+a+'\" target=\"_blank\">'+a+'</a>'});
//                }
//                   if(attach.type == 'link'){
//                   attach.link.description = attach.link.description.replace(/(?:(?:(?:https?|ftp|telnet):\/\/)?(?:[a-z0-9_-]{1,32}(?::[a-z0-9_-]{1,32})?@)?)?(?:(?:[a-z0-9-]{1,128}\.)+(?:ru|su|com|net|org|mil|edu|arpa|gov|biz|info|aero|inc|name|[a-z]{2})|(?!0)(?:(?!0[^.]|255)[0-9]{1,3}\.){3}(?!0|255)[0-9]{1,3})(?:\/[a-z0-9.,_@%&?+=\~/-]*)?(?:#[^ '\"&]*)?/ig,function(a,b){;return '<a href=\"'+a+'\" target=\"_blank\">'+a+'</a>'});
//                   attach.link.title = attach.link.title.replace(/(?:(?:(?:https?|ftp|telnet):\/\/)?(?:[a-z0-9_-]{1,32}(?::[a-z0-9_-]{1,32})?@)?)?(?:(?:[a-z0-9-]{1,128}\.)+(?:ru|su|com|net|org|mil|edu|arpa|gov|biz|info|aero|inc|name|[a-z]{2})|(?!0)(?:(?!0[^.]|255)[0-9]{1,3}\.){3}(?!0|255)[0-9]{1,3})(?:\/[a-z0-9.,_@%&?+=\~/-]*)?(?:#[^ '\"&]*)?/ig,function(a,b){;return '<a href=\"'+a+'\" target=\"_blank\">'+a+'</a>'});
//           }
//        });
//       }
       return item;
    });
}
server.on('request', (req,res)=>{
    var print = (obj)=>{
        var reply = JSON.stringify(obj);
        res.writeHead(200,{
                    'Content-Type':'application/json',
                    'Access-Control-Allow-Origin':'http://localhost:9000'
                });
        res.write(reply);
        res.end();
    }
	var query = url.parse(req.url).query;
	var query = querystring.parse(query);

	var countT = parseInt(query.count) || 1;
	var idT = parseInt(query.id) || 1;
    id = idT>0?idT:1; 
	var offsetT = parseInt(query.offset) || 0;
    var offset = offsetT>=0 ? offsetT : 0;
    var count = countT>0 ? countT : 1;
    var options = {
        protocol: 'https',
        host: 'api.vk.com',
        pathname: '/method/wall.get',
        query: {
            owner_id: id,
            offset: offset,
            v:'5.60',
            count: count
        }
    };
	var needUrl = url.format(options);
	request(needUrl,(err,response,body)=>{
        var options =  {
            protocol: 'https',
            host: 'api.vk.com',
            pathname: '/method/users.get',
            query: {
                user_id: id,
                v: '5.60'
            }
        };
        var needUrl = url.format(options);
        var obj = JSON.parse(body);
        if(obj.error){
            var reply = {response:{error: true,user:true}};
            print(reply);
        }else{
            request(needUrl, (err,response,body)=>{
                    var body = JSON.parse(body);
                    if(body.error){
                        obj.response.error = true;
                    }else{
                        var name = body.response[0].first_name;
                        var last_name = body.response[0].last_name;
                        obj.response.first_name = name;
                        obj.response.last_name = last_name;
                        obj.response.items = modify(obj.response.items);
                    }
                    print(obj)
                    var reply = JSON.stringify(obj);
            });
        }
	});
});