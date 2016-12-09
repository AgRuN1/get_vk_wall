getWall = angular.module('getWall',['ngAnimate']);
getWall.controller('getWallCtrl',($scope,$http,$sce)->
    $scope.sce = $sce
    $scope.id
    $scope.count = 0
    $scope.getCount = 0
    $scope.list = []
    #quantity posts
    $scope.check = true
    #quantity recieved posts 
    $scope.unknownError = ()->
        $scope.show('Что-то пошло не так...','danger')
    $scope.closeGet = ()->
        $('.loading').remove()
        $scope.check = true
    $scope.loadMore = ()->
        console.log 'work'
        $('.more').remove()
        $scope.check = true
        $scope.addPosts()
    $scope.checkHeight = ()->
        setTimeout(()->
            if($scope.count > $scope.getCount && $(document).height() <= $(window).height())
                $scope.check = false
                $('.container').append('<div class="text-center more"><button class="btn btn-primary">Еще</button></div>')
                $('.more').click(()->
                    angular.element(maint).scope().loadMore()
                )
        ,1000
        )
    $scope.show = (text,classes) ->
        if(!document.getElementById('alert'))
            $('<aside role="alert" class="alert alert-'+classes+'" id="alert"><strong>'+text+'</strong></aside>').insertBefore('#main')
        null
    $scope.hide = ->
        if(document.getElementById('alert'))
            $('#alert').remove()
        null  
    $scope.get = ->
        id = $('#id').val() 
        count = $('#count').val()
        $scope.hide()
        if(isNaN(id) || !id || id<1) 
            $scope.show('Введите числовой id','danger')
            return
        if(isNaN(count) || !count || id<1)
            $scope.show('Введите сколько записей вы хотите получить','danger')
            return
        $scope.id = parseInt(id)
        $scope.count = parseInt(count)
        if(count > 10)
            count = 10
        $http.get('http://localhost:8080?id=' + id + "&count=" + count)
        .success((data)->
            if(data.response.error)
                if(data.response.user)
                    $scope.show('Данный пользователь закрыл доступ к своей стене!','warning')
                else
                    $scope.unknownError()
            else
                $scope.getCount = parseInt(count)
                $scope.list = data.response.items
                $scope.name = data.response.first_name+ " " + data.response.last_name
                $scope.show($scope.print(),'success')
                $scope.checkHeight()
        )
        .error(()-> 
            $scope.unknownError()
        )
    $scope.print = ->
        end = 'о' 
        post = 'ей'
        if($scope.count % 10 == 1 && $scope.count % 100 != 11)
            end = 'a'
            post = 'ь'
        else if(($scope.count % 10 == 2 || $scope.count % 10 == 3 || $scope.count % 10 == 4) && ($scope.count % 100 != 12 && $scope.count % 100 != 13 && $scope.count % 100 != 14)) 
                post = 'и'
        reply = 'Успешно получен'+end+' '+$scope.count+' запис'+post+' от пользователя '+$scope.name
        return reply
    $scope.addPosts = () ->
        if($scope.check && $scope.count > $scope.getCount && $scope.id)
            $scope.check = false
            $('.container').append('<div class="text-center loading"><i class="fa fa-spinner fa-pulse fa-3x"></i></div>')
            count = $scope.count - $scope.getCount;
            if(parseInt(count) > 10)
                count = 10
            $http.get('http://localhost:8080?id='+$scope.id+'&count='+count+'&offset='+$scope.getCount)
            .success((data)->
                $scope.getCount += parseInt(count)
                if(data.response.items)
                    for item in data.response.items
                        $scope.list.push(item)
                        $scope.checkHeight()
                else
                    $scope.unknownError()
                $scope.closeGet()

            ).error(()->
                $scope.unknownError()
                $scope.closeGet()
        
            )
)

getWall.directive('attachment',()->
    return {
        link: (scope,element,attrs)->
            attach = JSON.parse(attrs.attachment)
            if(attach.type == 'link')
                element.append('<div><p><a href="'+attach.link.url+'" target="_blank">'+attach.link.title+'</a></p><p>'+attach.link.description+'</p></div>')
            if(attach.type == 'photo')
                photo = attach.photo.photo_807
                if(!photo)
                    photo = attach.photo.photo_604
                element.append('
                <div class="modal" id="'+attach.photo.access_key+'" tabindex="-1" role="dialog">
                  <div class="modal-dialog modal-lg" role="document">
                    <div class="modal-content">
                      <div class="modal-header">
                        <button type="button" class="close" data-dismiss="modal">&times;</button>
                        <div class="modal-title text-center">'+attach.photo.text+'</div>
                      </div>
                      <div class="modal-body text-center">
                        <img src="'+photo+'">
                      </div>
                    </div>
                  </div>
                </div>
                ')
                element.append('<img title="Открыть картинку" class="pict"src="'+attach.photo.photo_130+'"data-toggle="modal" data-target="#'+attach.photo.access_key+'">')
            if(attach.type == 'video')
                photo = attach.video.photo_800
                if(!photo)
                    photo = attach.video.photo_320
                element.append('
                <div class="modal" id="'+attach.video.access_key+'" tabindex="-1" role="dialog">
                  <div class="modal-dialog modal-lg" role="document">
                    <div class="modal-content">
                      <div class="modal-header">
                        <button type="button" class="close" data-dismiss="modal">&times;</button>
                        <div class="modal-title text-center">'+attach.video.title+'</div>
                      </div>
                      <div class="modal-body text-center">
                        <p>'+attach.video.description+'</p>
                        <img src="'+photo+'">
                      </div> 
                    </div>
                  </div>
                </div>
                ')
                element.append('<img title="Открыть картинку" class="pict" src="'+attach.video.photo_130+'"data-toggle="modal" data-target="#'+attach.video.access_key+'">')
            if(attach.type == 'doc')
                size = Math.floor(parseInt(attach.doc.size)/(1024*1024))
                element.append('<p><a href="'+attach.doc.url+'" target="_blank">'+attach.doc.title+'</a> <span>'+size+' Mб</span></p>')
            null
        
    }
)

getWall.filter('date',()->
    return (str)->
        moment.locale('ru')
        return moment.unix(str).format("LL")
)

$(window).scroll(()->
    windowHeight = $(document).height() - $(window).height()
    current = $(document).scrollTop()
    if(current > $(window).height())
        $('.to-top').css(display: 'block')
    if(current < $(window).height())
        $('.to-top').css(display: 'none')
    if(windowHeight == current)
        angular.element(maint).scope().addPosts();
)
$('.to-top').click(()->
    $(document).scrollTop(0)
)
