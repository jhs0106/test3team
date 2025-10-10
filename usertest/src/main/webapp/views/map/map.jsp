<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<style>
    #map{
        width:auto;
        height:400px;
        border:2px solid red;
    }
</style>

<script>
    kakao.maps.load(function () {
        var mapContainer = document.getElementById('map'); // 지도를 표시할 div
        if (!mapContainer) return; // 방어코드

        var mapOption = {
            center: new kakao.maps.LatLng(36.800209, 127.074968), // 중심좌표
            level: 5                                              // 확대 레벨
        };

        var map = new kakao.maps.Map(mapContainer, mapOption);
    });
</script>


<div class="col-sm-10">
    <h2>Map</h2>
    <div id="map"></div>
</div>