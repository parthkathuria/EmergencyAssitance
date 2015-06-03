<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="index.aspx.cs" Inherits="EmergencyApp.index" %>

<!DOCTYPE html>
<html lang="en">

<head>

    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <meta name="description" content="">
    <meta name="author" content="">

    <title>Emergency Assistance</title>

    <!-- Bootstrap Core CSS -->
    <link href="css/bootstrap.min.css" rel="stylesheet">
    <link href="css/flatly.css" rel="stylesheet" />
    <link href="https://maxcdn.bootstrapcdn.com/font-awesome/4.3.0/css/font-awesome.min.css" rel="stylesheet">
    <!-- Custom CSS -->
    <style>
        body {
            padding-top: 70px;
            /* Required padding for .navbar-fixed-top. Remove if using .navbar-static-top. Change if height of navigation changes. */
        }
    </style>
    <style>
      .placeIcon {
        width: 20px;
        height: 34px;
        margin: 4px;
      }
      .hotelIcon {
        width: 24px;
        height: 24px;
      }
      #rating {
        font-size: 13px;
        font-family: Arial Unicode MS;
      }
      .iw_table_row {
        height: 18px;
      }
      .iw_attribute_name {
        font-weight: bold;
        text-align: right;
      }
      .iw_table_icon {
        text-align: right;
      }
    </style>
    <!-- jQuery Version 1.11.1 -->
    <script src="js/jquery.js"></script>
    <script src="js/stupidtable.min.js"></script>
    <%--<script src="js/jquery.tablesorter.min.js"></script>--%>
    <!-- Bootstrap Core JavaScript -->
    <script src="js/bootstrap.min.js"></script>
    <!-- HTML5 Shim and Respond.js IE8 support of HTML5 elements and media queries -->
    <!-- WARNING: Respond.js doesn't work if you view the page via file:// -->
    <!--[if lt IE 9]>
        <script src="https://oss.maxcdn.com/libs/html5shiv/3.7.0/html5shiv.js"></script>
        <script src="https://oss.maxcdn.com/libs/respond.js/1.4.2/respond.min.js"></script>
    <![endif]-->
    <script src="https://maps.googleapis.com/maps/api/js?v=3.exp&key=AIzaSyBWirhAMk3eToYUs0FxzuXhC9VHQlclEPI&libraries=places"></script>

    <script type="text/javascript">

        var map, places, infoWindow, pos,currentPosition;
        var markers = [];
        var list = [];
        var marker = null;
        var autocomplete;
        var countryRestrict = { 'country': 'us' };
        var MARKER_PATH = 'https://maps.gstatic.com/intl/en_us/mapfiles/marker_green';
        var hostnameRegexp = new RegExp('^https?://.+?/');
        
        var trafficLayer = new google.maps.TrafficLayer();

        function initialize() {
            sessionStorage.clear();
            $("#resultsTable").stupidtable();
            document.getElementById("resultsTable").style.display = "none";
            var myOptions = {
                zoom: 12,
                center: new google.maps.LatLng(37.1, -95.7),
                mapTypeControl: false,
                panControl: false,
                zoomControl: false,
                streetViewControl: false,
                mapTypeId: google.maps.MapTypeId.ROADMAP
            };

            map = new google.maps.Map(document.getElementById('map-canvas'), myOptions);
            
            trafficLayer.setMap(map);
            marker = new google.maps.Marker({
                position: new google.maps.LatLng(37.1, -95.7),
                map: map,
                animation: google.maps.Animation.DROP
            });
            currentLocation();
            infoWindow = new google.maps.InfoWindow({
                content: document.getElementById('info-content')
            });

            // Create the autocomplete object and associate it with the UI input control.
            // Restrict the search to the default country, and to place type "cities".
            autocomplete = new google.maps.places.Autocomplete(
                /** @type {HTMLInputElement} */(document.getElementById('autocomplete')),
                {
                    types: ['establishment','geocode'],
                    componentRestrictions: countryRestrict
                });
            places = new google.maps.places.PlacesService(map);

            google.maps.event.addListener(autocomplete, 'place_changed', onPlaceChanged);
        }


        function currentLocation() {
            document.getElementById('autocomplete').value = "";
            if (navigator.geolocation) {
                navigator.geolocation.getCurrentPosition(function (position) {
                    pos = new google.maps.LatLng(position.coords.latitude,
                                                     position.coords.longitude);

                    //var infowindow = new google.maps.InfoWindow({
                    //    map: map,
                    //    position: pos,
                    //    content: 'Location found using HTML5.'
                    //});
                    marker.setMap(null);
                    marker = new google.maps.Marker({
                        position: pos,
                        map: map,
                        animation: google.maps.Animation.DROP
                    });
                    map.setCenter(pos);
                    currentPosition = pos;
                    //document.getElementById("position").value = pos;
                }, function () {
                    handleNoGeolocation(true);
                });
            } else {
                // Browser doesn't support Geolocation
                handleNoGeolocation(false);
            }
        }

        function handleNoGeolocation(errorFlag) {
            if (errorFlag) {
                var content = 'Error: The Geolocation service failed.';
            } else {
                var content = 'Error: Your browser doesn\'t support geolocation.';
            }

            var options = {
                map: map,
                position: new google.maps.LatLng(37.1, -95.7),
                content: content
            };
            marker = new google.maps.Marker({
                position: new google.maps.LatLng(37.1, -95.7),
                map: map,
                animation: google.maps.Animation.DROP
            });
            var infowindow = new google.maps.InfoWindow(options);
            map.setCenter(options.position);
        }

        function onPlaceChanged() {
            var place = autocomplete.getPlace();
            //console.log(place);
            if (place.geometry) {
                map.panTo(place.geometry.location);
                map.setZoom(12);
                marker.setMap(null);
                marker = new google.maps.Marker({
                    position: place.geometry.location,
                    animation: google.maps.Animation.DROP,
                    map: map
                });
                currentPosition = place.geometry.location;
                //document.getElementById("position").value = place.geometry.location;
                //search(place.geometry.location);
            } else {
                document.getElementById('autocomplete').placeholder = 'Enter a city';
            }

        }
        var locList;
        function search() {
            //alert(map.getBounds());
            var location = map.getBounds().getNorthEast();
            //alert(location);
            //var search = {
            //    bounds:map.getBounds(),
            //    types: ['health', 'doctor', 'hospital', 'dentist'],
            //};
            var search = {
                location: currentPosition,
                radius: '10000',
                types: ['health', 'doctor', 'hospital', 'dentist'],
                keyword: ['hospital', 'medical','clinic'],
                rankby: google.maps.places.RankBy.DISTANCE
            };
            //console.log(search);
            document.getElementById("resultsTable").style.display = "inherit";
            places.nearbySearch(search, function (results, status) {
                if (status == google.maps.places.PlacesServiceStatus.OK) {
                    clearResults();
                    clearMarkers();
                    locList = results;
                    //console.log(locList);
                    // Create a marker for each hotel found, and
                    // assign a letter of the alphabetic to each marker icon.
                    
                    for (var i = 0; i < results.length; i++) {
                        var markerLetter = String.fromCharCode('A'.charCodeAt(0) + i);
                        var markerIcon = MARKER_PATH + markerLetter + '.png';
                        //var markerIcon = "http://maps.gstatic.com/mapfiles/place_api/icons/doctor-71.png";
                        // Use marker animation to drop the icons incrementally on the map.
                        //list[i] = results[i];
                        //console.log(list[i]);
                        //var time = getTime(list[i]);
                        //console.log(time);
                        markers[i] = new google.maps.Marker({
                            position: results[i].geometry.location,
                            animation: google.maps.Animation.DROP,
                            icon: markerIcon
                        });
                        // If the user clicks a hotel marker, show the details of that hotel
                        // in an info window.
                        
                        markers[i].placeResult = results[i];
                        google.maps.event.addListener(markers[i], 'click', showInfoWindow);
                        setTimeout(dropMarker(i), i * 100);
                        setTime(i);
                        // addRes(results[i], i);
                        //getTime(results[i]);
                    }
                }
            });
           
        }
      //  var time = {};
        var temp;        
        function getTime() {
            //console.log(locList);
            for (var i = 0; i < locList.length; i++) {
               
                //console.log("temp: " + temp.location);
                setTime(i);
                console.log(i);
                //console.log("temp1: " +temp.time);
                //addResult(locList[i], i, temp);
            }
            
        }
        function setTime(i) {
            //var i = 0;
            var request = {
                origins: [currentPosition],
                destinations: [locList[i].geometry.location],
                travelMode: google.maps.TravelMode.DRIVING,
                durationInTraffic: true,
                unitSystem: google.maps.UnitSystem.IMPERIAL
            };
            var directionsService = new google.maps.DistanceMatrixService();
            //console.log(locList[i].name);
            directionsService.getDistanceMatrix(request, function (response, status) {
                if (status == google.maps.DistanceMatrixStatus.OK) {
                    t = response.rows[0].elements[0].duration.text;
                    d = response.rows[0].elements[0].distance.text;
                    //console.log(locList[i].geometry.location);
                    // temp["location"] =
                    temp = {
                        time: t,
                        dist: d
                    }
                   
                    addResult(locList[i], i, temp);
                    
                }
            });
            //console.log(i);
            //console.log(temp);
        }
        function clearMarkers() {
            for (var i = 0; i < markers.length; i++) {
                if (markers[i]) {
                    markers[i].setMap(null);
                }

            }
            markers = [];
        }
        
        function dropMarker(i) {
            return function () {
                markers[i].setMap(map);
            };
        }

        function addRes(result, i) {
            //console.log(result.name);
            var results = document.getElementById('results');
            var markerLetter = String.fromCharCode('A'.charCodeAt(0) + i);
            var markerIcon = MARKER_PATH + markerLetter + '.png';

            var tr = document.createElement('tr');
            // tr.style.backgroundColor = (i % 2 == 0 ? '#F0F0F0' : '#FFFFFF');
            tr.onclick = function () {
                google.maps.event.trigger(markers[i], 'click');
            };

            var iconTd = document.createElement('td');
            var nameTd = document.createElement('td');
            var btnTd = document.createElement('td');
            var icon = document.createElement('img');
            var btn = document.createElement('a');
            btn.name = 'route' + i;
            btn.id = 'route' + i;
            btn.className = 'btn btn-primary';
            btn.innerHTML = 'Get Route';
            var t = "getRoute(" + i + ")";
            btn.setAttribute('onclick', t);
            icon.src = markerIcon;
            icon.setAttribute('class', 'placeIcon');
            icon.setAttribute('className', 'placeIcon');
            var html = result.name;
            var name = document.createTextNode(html);
            iconTd.appendChild(icon);
            nameTd.appendChild(name);
            btnTd.appendChild(btn);
            tr.appendChild(iconTd);
            tr.appendChild(nameTd);
            tr.appendChild(btnTd);
            results.appendChild(tr);
        }
        function addResult(result, i, temp) {
            //console.log(result.name);
            var results = document.getElementById('results');
            var markerLetter = String.fromCharCode('A'.charCodeAt(0) + i);
            var markerIcon = MARKER_PATH + markerLetter + '.png';
            
            var tr = document.createElement('tr');
           // tr.style.backgroundColor = (i % 2 == 0 ? '#F0F0F0' : '#FFFFFF');
            tr.onclick = function () {
                google.maps.event.trigger(markers[i], 'click');
            };

            var iconTd = document.createElement('td');
            var nameTd = document.createElement('td');
            var timeTd = document.createElement('td');
            var distTd = document.createElement('td');
            var btnTd = document.createElement('td');
            var icon = document.createElement('img');
            var btn = document.createElement('a');
            btn.name = 'route' + i;
            btn.id = 'route' + i;
            btn.className = 'btn btn-primary';
            btn.innerHTML = 'Get Route';
            var t = "getRoute("+i+")";
            btn.setAttribute('onclick', t);
            icon.src = markerIcon;
            icon.setAttribute('class', 'placeIcon');
            icon.setAttribute('className', 'placeIcon');
            var html = result.name;
            var name = document.createTextNode(html);
            var time = document.createTextNode(temp.time);
            var dist = document.createTextNode(temp.dist);
            iconTd.appendChild(icon);
            nameTd.appendChild(name);
            timeTd.appendChild(time);
            distTd.appendChild(dist);
            btnTd.appendChild(btn);
            tr.appendChild(iconTd);
            tr.appendChild(nameTd);
            tr.appendChild(timeTd);
            tr.appendChild(distTd);
            tr.appendChild(btnTd);
            results.appendChild(tr);
        }
        function clearResults() {
            var results = document.getElementById('results');
            while (results.childNodes[0]) {
                results.removeChild(results.childNodes[0]);
            }
        }
        function showInfoWindow() {
            var marker = this;
            document.getElementById("info-content").style.display = 'inherit';
            places.getDetails({ placeId: marker.placeResult.place_id },
                function (place, status) {
                    if (status != google.maps.places.PlacesServiceStatus.OK) {
                        return;
                    }
                    infoWindow.open(map, marker);
                    buildIWContent(place);
                });
        }

        function getRoute(i) {
            if (typeof (Storage) !== "undefined") {
                //var location = locList[i].geometry.location.tostring();
                var origin = ""+currentPosition+"";
                var dest = ""+locList[i].geometry.location +"";
                var request = {
                    origin: origin,
                    destination: dest,
                    travelMode: google.maps.TravelMode.DRIVING,
                    durationInTraffic: true,
                    unitSystem: google.maps.UnitSystem.IMPERIAL
                };
                sessionStorage.setItem("request", JSON.stringify(request));
                window.location.href = "route.aspx";
            } else {
                // Sorry! No Web Storage support..
                console.log("error");
            }
        }
        function buildIWContent(place) {
            document.getElementById('iw-icon').innerHTML = '<img class="hotelIcon" ' +
                'src="' + place.icon + '"/>';
            document.getElementById('iw-url').innerHTML = '<b><a href="' + place.url +
                '">' + place.name + '</a></b>';
            document.getElementById('iw-address').textContent = place.vicinity;

            if (place.formatted_phone_number) {
                document.getElementById('iw-phone-row').style.display = '';
                document.getElementById('iw-phone').textContent =
                    place.formatted_phone_number;
            } else {
                document.getElementById('iw-phone-row').style.display = 'none';
            }

            // Assign a five-star rating to the hotel, using a black star ('&#10029;')
            // to indicate the rating the hotel has earned, and a white star ('&#10025;')
            // for the rating points not achieved.
            if (place.rating) {
                var ratingHtml = '';
                for (var i = 0; i < 5; i++) {
                    if (place.rating < (i + 0.5)) {
                        ratingHtml += '&#10025;';
                    } else {
                        ratingHtml += '&#10029;';
                    }
                    document.getElementById('iw-rating-row').style.display = '';
                    document.getElementById('iw-rating').innerHTML = ratingHtml;
                }
            } else {
                document.getElementById('iw-rating-row').style.display = 'none';
            }

            // The regexp isolates the first part of the URL (domain plus subdomain)
            // to give a short URL for displaying in the info window.
            if (place.website) {
                var fullUrl = place.website;
                var website = hostnameRegexp.exec(place.website);
                if (website == null) {
                    website = 'http://' + place.website + '/';
                    fullUrl = website;
                }
                document.getElementById('iw-website-row').style.display = '';
                document.getElementById('iw-website').textContent = website;
            } else {
                document.getElementById('iw-website-row').style.display = 'none';
            }
        }
    </script>
</head>

<body onload="initialize()">
    <form id="form1" runat="server">
        <!-- Navigation -->
        <nav class="navbar navbar-default navbar-fixed-top" role="navigation">
            <div class="container">
                <!-- Brand and toggle get grouped for better mobile display -->
                <div class="navbar-header">
                    <button type="button" class="navbar-toggle" data-toggle="collapse" data-target="#bs-example-navbar-collapse-1">
                        <span class="sr-only">Toggle navigation</span>
                        <span class="icon-bar"></span>
                        <span class="icon-bar"></span>
                        <span class="icon-bar"></span>
                    </button>
                    <a class="navbar-brand" href="index.aspx"><i class="fa fa-ambulance"></i> Emergency Assistance <i class="fa fa-stethoscope"></i></a>
                </div>
                <!-- Collect the nav links, forms, and other content for toggling -->
                <div class="collapse navbar-collapse" id="bs-example-navbar-collapse-1">
                    <%--<ul class="nav navbar-nav">
                        <li>
                            <a href="#">About</a>
                        </li>
                        <li>
                            <a href="#">Services</a>
                        </li>
                        <li>
                            <a href="#">Contact</a>
                        </li>
                    </ul>--%>
                    <ul class="nav navbar-nav navbar-right">
                        <li><a href="login.aspx">Login</a></li>
                        <li><a href="register.aspx">Register</a></li>
                      </ul>
                </div>
                <!-- /.navbar-collapse -->
            </div>
            <!-- /.container -->
        </nav>

        <!-- Page Content -->
        <div class="container">
            <div class="row">
                <div class="col-lg-3 col-lg-offset-9">
                    <img src="images/ambulance_banner.jpg" style="width:300px; height:100px" />
                </div>
            </div>
            <div class="row">
                
                <div class="col-lg-6">
                    <div class="col-lg-12">
                        <div class="input-group">

                            <a onclick="currentLocation()" class="input-group-addon"><i class="glyphicon glyphicon-map-marker"></i></a>
                            <asp:TextBox ID="autocomplete" runat="server" CssClass="form-control" placeholder="Enter City..." onkeydown = "return (event.keyCode!=13);"></asp:TextBox>
                            <span class="input-group-btn">                                
                                <input type="button" class="btn btn-primary" onclick="search()" value="Search Nearby Hospitals"/>
                                <%--<input type="button" class="btn btn-primary" value="Get List" onclick="getTime();" />--%>
                               <%-- <asp:Button ID="btnSearch" runat="server" CssClass="btn btn-default" Text="Search Nearby Hospitals" OnClientClick="search()"/>--%>
                            </span>
                        </div>

                    </div>
                    <div class="col-lg-12">
                        <div id="map-canvas" class="panel panel-default" style="width: 100%; height: 525px;"></div>
                    </div>
                </div>
                <div class="col-lg-6">
                    <%--<input type="button" class="btn btn-default" value="Sort By Time" onclick="sortTable();"/>--%>
                    <div class="table-responsive" style="height:580px;overflow-y:auto">
                    <table id="resultsTable" class="table table-hover">
                        <thead>
                                <tr>
                                <th></th>
                                <th data-sort="string"><a href="#">Name</a></th>
                                <th data-sort="float"><a href="#">Duration</a></th>
                                <th data-sort="float"><a href="#">Distance</a></th>
                                </tr>
                            </thead>
                        <tbody id="results"></tbody>
                      </table>
                        </div>
                </div>
                <div class="col-lg-12">
                    <div id="info-content" style="display:none" >
                        <table class="table table-hover">
                            <tr id="iw-url-row" class="iw_table_row">
                                <td id="iw-icon" class="iw_table_icon"></td>
                                <td id="iw-url"></td>
                            </tr>
                            <tr id="iw-address-row" class="iw_table_row">
                                <td class="iw_attribute_name">Address:</td>
                                <td id="iw-address"></td>
                            </tr>
                            <tr id="iw-phone-row" class="iw_table_row">
                                <td class="iw_attribute_name">Telephone:</td>
                                <td id="iw-phone"></td>
                            </tr>
                            <tr id="iw-rating-row" class="iw_table_row">
                                <td class="iw_attribute_name">Rating:</td>
                                <td id="iw-rating"></td>
                            </tr>
                            <tr id="iw-website-row" class="iw_table_row">
                                <td class="iw_attribute_name">Website:</td>
                                <td id="iw-website"></td>
                            </tr>
                        </table>
                    </div>
                </div>
            </div>
            <!-- /.row -->

        </div>
        <!-- /.container -->
    </form>
</body>

</html>
