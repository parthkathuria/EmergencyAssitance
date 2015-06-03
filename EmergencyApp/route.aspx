<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="route.aspx.cs" Inherits="EmergencyApp.route" %>

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
    <script src="js/jquery.tablesorter.min.js"></script>
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

        var map;
        var rendererOptions = {
            draggable: true
        };
        var trafficLayer = new google.maps.TrafficLayer();

        var request = null;
        var directionsService = new google.maps.DirectionsService();
        var directionsDisplay;
        
        function initialize() {
            directionsDisplay = new google.maps.DirectionsRenderer(rendererOptions);
            if (typeof (Storage) !== "undefined") {
                request = JSON.parse(sessionStorage.getItem("request"));
                console.log(request);
            } else {
                // Sorry! No Web Storage support..
                console.log("error");
            }
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
            directionsDisplay.setMap(map);
            directionsDisplay.setPanel(document.getElementById('directions-panel'));
            marker = new google.maps.Marker({
                position: new google.maps.LatLng(37.1, -95.7),
                map: map,
                animation: google.maps.Animation.DROP
            });
            directionsService.route(request, function (response, status) {
                if (status == google.maps.DirectionsStatus.OK) {
                    directionsDisplay.setDirections(response);
                }
            });
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
                        <li><a href="#"><i class="fa fa-car"></i> Reserver Parking</a></li>
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
                
                <div class="col-lg-6">
                    <div class="col-lg-12">
                        <div id="map-canvas" class="panel panel-default" style="width: 100%; height: 550px;"></div>
                    </div>
                </div>
                <div class="col-lg-6">
                    <div id="directions-panel" class="panel panel-default"></div>
                </div>
            </div>
            <!-- /.row -->

        </div>
        <!-- /.container -->
    </form>
</body>

</html>
