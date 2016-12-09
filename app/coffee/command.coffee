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
            console.log attach.type
            if(attach.type == 'link')
                element.append('<div><p><a href="'+attach.link.url+'">'+attach.link.title+'</a></p><p>'+attach.link.description+'</p></div>')
            if(attach.type == 'photo')
                element.append('<img src="'+attach.photo.photo_604+'" width="350" height="350">')
            if(attach.type == 'video')
                element.append('<p>'+attach.video.title+'</p><p><img src="'+attach.video.photo_320+'"><p>')
            null
        
    }
)
#
#myModule.animation('.repeated-item', () ->
#    return {
#    enter : (element, done) ->
#        element.css('opacity',0)
#        jQuery(element).animate({
#            opacity: 1
#        }, done)
#        return (isCancelled) ->
#            if(isCancelled) 
#                jQuery(element).stop()
#    ,
#    leave : (element, done) ->
#        element.css('opacity', 1)
#        jQuery(element).animate({
#            opacity: 0
#        }, done)
#        return (isCancelled) ->
#            if(isCancelled) 
#                jQuery(element).stop()
#    ,
#    move : (element, done) ->
#        element.css('opacity', 0)
#        jQuery(element).animate({
#            opacity: 1
#        }, done)
#        return (isCancelled) ->
#            if(isCancelled) 
#                jQuery(element).stop()
#    ,
#    addClass : (element, className, done)-> null ,
#    removeClass : (element, className, done) ->null
#    }
#)

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
