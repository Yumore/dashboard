// Real Finnkino XML responses, copied verbatim from the inKino source
// repository's ignore-listed test seeds at git HEAD d406a23c3b57
// (core/test/parsers/{show,theater,event}_test_seeds.ignore.dart).
//
// They are the exact payloads the source's parser tests asserted against,
// so they double as the port's parser fixtures. The bytes are unmodified.

const String showsXml = '''<?xml version="1.0"?>
<Schedule xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
    <PubDate>2018-02-21T00:00:00+02:00</PubDate>
    <Shows>
        <Show>
            <ID>1155306</ID>
            <dtAccounting>2018-02-21T00:00:00</dtAccounting>
            <dttmShowStart>2018-02-21T10:30:00</dttmShowStart>
            <dttmShowStartUTC>2018-02-21T08:30:00Z</dttmShowStartUTC>
            <dttmShowEnd>2018-02-21T12:39:00</dttmShowEnd>
            <dttmShowEndUTC>2018-02-21T10:39:00Z</dttmShowEndUTC>
            <ShowSalesStartTime>2000-01-01T00:00:00</ShowSalesStartTime>
            <ShowSalesStartTimeUTC>2000-01-01T00:00:00Z</ShowSalesStartTimeUTC>
            <ShowSalesEndTime>2018-02-21T10:15:00</ShowSalesEndTime>
            <ShowSalesEndTimeUTC>2018-02-21T08:15:00Z</ShowSalesEndTimeUTC>
            <ShowReservationStartTime>2000-01-01T00:00:00</ShowReservationStartTime>
            <ShowReservationStartTimeUTC>2000-01-01T00:00:00Z</ShowReservationStartTimeUTC>
            <ShowReservationEndTime>2018-02-21T09:00:00</ShowReservationEndTime>
            <ShowReservationEndTimeUTC>2018-02-21T07:00:00Z</ShowReservationEndTimeUTC>
            <EventID>302419</EventID>
            <Title>Jumanji: Welcome to the Jungle</Title>
            <OriginalTitle>Jumanji: Welcome to the Jungle (This is the original title)</OriginalTitle>
            <ProductionYear>2017</ProductionYear>
            <LengthInMinutes>119</LengthInMinutes>
            <dtLocalRelease>2017-12-22T00:00:00</dtLocalRelease>
            <Rating>12</Rating>
            <RatingLabel>12</RatingLabel>
            <RatingImageUrl>https://media.finnkino.fi/images/rating_large_12.png</RatingImageUrl>
            <EventType>Movie</EventType>
            <Genres>Komedia, Toiminta, Seikkailu, Fantasia</Genres>
            <TheatreID>1038</TheatreID>
            <TheatreAuditriumID>1279</TheatreAuditriumID>
            <Theatre>Tennispalatsi, Helsinki</Theatre>
            <TheatreAuditorium>sali 6</TheatreAuditorium>
            <TheatreAndAuditorium>Tennispalatsi, Helsinki, sali 6</TheatreAndAuditorium>
            <PresentationMethodAndLanguage>2D</PresentationMethodAndLanguage>
            <PresentationMethod>2D</PresentationMethod>
            <EventSeries />
            <ShowURL>http://www.finnkino.fi/websales/show/1155306/</ShowURL>
            <EventURL>http://www.finnkino.fi/event/302419/title/jumanji_welcome_to_the_jungle/</EventURL>
            <Images>
                <EventMicroImagePortrait>http://media.finnkino.fi/1012/Event_11765/portrait_micro/Jumanji_1080u.jpg</EventMicroImagePortrait>
                <EventSmallImagePortrait>http://media.finnkino.fi/1012/Event_11765/portrait_small/Jumanji_1080u.jpg</EventSmallImagePortrait>
                <EventMediumImagePortrait>http://media.finnkino.fi/1012/Event_11765/portrait_medium/Jumanji_1080u.jpg</EventMediumImagePortrait>
                <EventLargeImagePortrait>http://media.finnkino.fi/1012/Event_11765/portrait_small/Jumanji_1080u.jpg</EventLargeImagePortrait>
                <EventSmallImageLandscape>http://media.finnkino.fi/1012/Event_11765/landscape_small/Jumanji_444.jpg</EventSmallImageLandscape>
                <EventLargeImageLandscape>http://media.finnkino.fi/1012/Event_11765/landscape_large/Jumanji_670.jpg</EventLargeImageLandscape>
            </Images>
            <ContentDescriptors>
                <ContentDescriptor>
                    <Name>Violence</Name>
                    <ImageURL>https://media.finnkino.fi/images/content_Violence.png</ImageURL>
                </ContentDescriptor>
                <ContentDescriptor>
                    <Name>Disturbing</Name>
                    <ImageURL>https://media.finnkino.fi/images/content_Disturbing.png</ImageURL>
                </ContentDescriptor>
            </ContentDescriptors>
        </Show>
        <Show>
            <ID>1154395</ID>
            <dtAccounting>2018-02-21T00:00:00</dtAccounting>
            <dttmShowStart>2018-02-21T10:30:00</dttmShowStart>
            <dttmShowStartUTC>2018-02-21T08:30:00Z</dttmShowStartUTC>
            <dttmShowEnd>2018-02-21T12:34:00</dttmShowEnd>
            <dttmShowEndUTC>2018-02-21T10:34:00Z</dttmShowEndUTC>
            <ShowSalesStartTime>2000-01-01T00:00:00</ShowSalesStartTime>
            <ShowSalesStartTimeUTC>2000-01-01T00:00:00Z</ShowSalesStartTimeUTC>
            <ShowSalesEndTime>2018-02-21T10:15:00</ShowSalesEndTime>
            <ShowSalesEndTimeUTC>2018-02-21T08:15:00Z</ShowSalesEndTimeUTC>
            <ShowReservationStartTime>2000-01-01T00:00:00</ShowReservationStartTime>
            <ShowReservationStartTimeUTC>2000-01-01T00:00:00Z</ShowReservationStartTimeUTC>
            <ShowReservationEndTime>2018-02-21T09:00:00</ShowReservationEndTime>
            <ShowReservationEndTimeUTC>2018-02-21T07:00:00Z</ShowReservationEndTimeUTC>
            <EventID>302486</EventID>
            <Title>Wonder</Title>
            <OriginalTitle>Wonder</OriginalTitle>
            <ProductionYear>2017</ProductionYear>
            <LengthInMinutes>114</LengthInMinutes>
            <dtLocalRelease>2018-01-05T00:00:00</dtLocalRelease>
            <Rating>S</Rating>
            <RatingLabel>S</RatingLabel>
            <RatingImageUrl>https://media.finnkino.fi/images/rating_large_S.png</RatingImageUrl>
            <EventType>Movie</EventType>
            <Genres>Draama</Genres>
            <TheatreID>1034</TheatreID>
            <TheatreAuditriumID>1207</TheatreAuditriumID>
            <Theatre>Kinopalatsi, Helsinki</Theatre>
            <TheatreAuditorium>sali 10</TheatreAuditorium>
            <TheatreAndAuditorium>Kinopalatsi, Helsinki, sali 10</TheatreAndAuditorium>
            <PresentationMethodAndLanguage>2D</PresentationMethodAndLanguage>
            <PresentationMethod>2D</PresentationMethod>
            <EventSeries />
            <ShowURL>http://www.finnkino.fi/websales/show/1154395/</ShowURL>
            <EventURL>http://www.finnkino.fi/event/302486/title/wonder/</EventURL>
            <Images>
                <EventMicroImagePortrait>http://media.finnkino.fi/1012/Event_11832/portrait_micro/Wonder_1080.jpg</EventMicroImagePortrait>
                <EventSmallImagePortrait>http://media.finnkino.fi/1012/Event_11832/portrait_small/Wonder_1080.jpg</EventSmallImagePortrait>
                <EventMediumImagePortrait>http://media.finnkino.fi/1012/Event_11832/portrait_medium/Wonder_1080.jpg</EventMediumImagePortrait>
                <EventLargeImagePortrait>http://media.finnkino.fi/1012/Event_11832/portrait_small/Wonder_1080.jpg</EventLargeImagePortrait>
                <EventSmallImageLandscape>http://media.finnkino.fi/1012/Event_11832/landscape_small/Wonder_444.jpg</EventSmallImageLandscape>
                <EventLargeImageLandscape>http://media.finnkino.fi/1012/Event_11832/landscape_large/Wonder_670.jpg</EventLargeImageLandscape>
            </Images>
            <ContentDescriptors />
        </Show>
        <Show>
            <ID>1153867</ID>
            <dtAccounting>2018-03-21T00:00:00</dtAccounting>
            <dttmShowStart>2018-03-21T10:30:00</dttmShowStart>
            <dttmShowStartUTC>2018-03-21T08:30:00Z</dttmShowStartUTC>
            <dttmShowEnd>2018-03-21T12:25:00</dttmShowEnd>
            <dttmShowEndUTC>2018-03-21T10:25:00Z</dttmShowEndUTC>
            <ShowSalesStartTime>2000-01-01T00:00:00</ShowSalesStartTime>
            <ShowSalesStartTimeUTC>2000-01-01T00:00:00Z</ShowSalesStartTimeUTC>
            <ShowSalesEndTime>2018-02-21T10:15:00</ShowSalesEndTime>
            <ShowSalesEndTimeUTC>2018-02-21T08:15:00Z</ShowSalesEndTimeUTC>
            <ShowReservationStartTime>2000-01-01T00:00:00</ShowReservationStartTime>
            <ShowReservationStartTimeUTC>2000-01-01T00:00:00Z</ShowReservationStartTimeUTC>
            <ShowReservationEndTime>2018-02-21T09:00:00</ShowReservationEndTime>
            <ShowReservationEndTimeUTC>2018-02-21T07:00:00Z</ShowReservationEndTimeUTC>
            <EventID>302492</EventID>
            <Title>The Greatest Showman</Title>
            <OriginalTitle>The Greatest Showman</OriginalTitle>
            <ProductionYear>2017</ProductionYear>
            <LengthInMinutes>105</LengthInMinutes>
            <dtLocalRelease>2018-01-19T00:00:00</dtLocalRelease>
            <Rating>7</Rating>
            <RatingLabel>7</RatingLabel>
            <RatingImageUrl>https://media.finnkino.fi/images/rating_large_7.png</RatingImageUrl>
            <EventType>Movie</EventType>
            <Genres>Draama, Musikaali, Elämäkerta</Genres>
            <TheatreID>1034</TheatreID>
            <TheatreAuditriumID>1266</TheatreAuditriumID>
            <Theatre>Kinopalatsi, Helsinki</Theatre>
            <TheatreAuditorium>sali 9</TheatreAuditorium>
            <TheatreAndAuditorium>Kinopalatsi, Helsinki, sali 9</TheatreAndAuditorium>
            <PresentationMethodAndLanguage>2D</PresentationMethodAndLanguage>
            <PresentationMethod>2D</PresentationMethod>
            <EventSeries />
            <ShowURL>http://www.finnkino.fi/websales/show/1153867/</ShowURL>
            <EventURL>http://www.finnkino.fi/event/302492/title/the_greatest_showman/</EventURL>
            <Images>
                <EventMicroImagePortrait>http://media.finnkino.fi/1012/Event_11838/portrait_micro/TheGreatestShowman_1080.jpg</EventMicroImagePortrait>
                <EventSmallImagePortrait>http://media.finnkino.fi/1012/Event_11838/portrait_small/TheGreatestShowman_1080.jpg</EventSmallImagePortrait>
                <EventMediumImagePortrait>http://media.finnkino.fi/1012/Event_11838/portrait_medium/TheGreatestShowman_1080.jpg</EventMediumImagePortrait>
                <EventLargeImagePortrait>http://media.finnkino.fi/1012/Event_11838/portrait_small/TheGreatestShowman_1080.jpg</EventLargeImagePortrait>
                <EventSmallImageLandscape>http://media.finnkino.fi/1012/Event_11838/landscape_small/TheGreatestShowman_444.jpg</EventSmallImageLandscape>
                <EventLargeImageLandscape>http://media.finnkino.fi/1012/Event_11838/landscape_large/TheGreatestShowman_670.jpg</EventLargeImageLandscape>
            </Images>
            <ContentDescriptors>
                <ContentDescriptor>
                    <Name>Violence</Name>
                    <ImageURL>https://media.finnkino.fi/images/content_Violence.png</ImageURL>
                </ContentDescriptor>
                <ContentDescriptor>
                    <Name>Disturbing</Name>
                    <ImageURL>https://media.finnkino.fi/images/content_Disturbing.png</ImageURL>
                </ContentDescriptor>
            </ContentDescriptors>
        </Show>
    </Shows>
</Schedule>''';

const String theatersXml = '''<?xml version="1.0"?>
<TheatreAreas xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
    <TheatreArea>
        <ID>1029</ID>
        <Name>Valitse alue/teatteri</Name>
    </TheatreArea>
    <TheatreArea>
        <ID>001</ID>
        <Name>Gotham: THEATER ONE</Name>
    </TheatreArea>
    <TheatreArea>
        <ID>002</ID>
        <Name>Gotham: THEATER TWO</Name>
    </TheatreArea>
</TheatreAreas>''';

const String eventsXml = '''<?xml version="1.0"?>
<Events xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
    <Event>
        <ID>302535</ID>
        <Title>15:17 Pariisiin (2D dub)</Title>
        <OriginalTitle>The 15:17 to Paris (2D dub)</OriginalTitle>
        <ProductionYear>2018</ProductionYear>
        <LengthInMinutes>94</LengthInMinutes>
        <dtLocalRelease>2018-02-16T00:00:00</dtLocalRelease>
        <Rating>12</Rating>
        <RatingLabel>12</RatingLabel>
        <RatingImageUrl>https://media.finnkino.fi/images/rating_large_12.png</RatingImageUrl>
        <LocalDistributorName>SF Film Finland Oy</LocalDistributorName>
        <GlobalDistributorName>SF Film Finland Oy</GlobalDistributorName>
        <ProductionCompanies>-</ProductionCompanies>
        <EventType>Movie</EventType>
        <Genres>Draama, Jännitys</Genres>
        <ShortSynopsis>Short synopsis goes here.</ShortSynopsis>
        <Synopsis>Synopsis goes here.</Synopsis>
        <EventURL>http://www.finnkino.fi/event/302535/title/1517_pariisiin/</EventURL>
        <Images>
            <EventSmallImagePortrait>http://media.finnkino.fi/1012/Event_11881/portrait_small/The1517toParis_1080.jpg</EventSmallImagePortrait>
            <EventMediumImagePortrait>http://media.finnkino.fi/1012/Event_11881/portrait_medium/The1517toParis_1080.jpg</EventMediumImagePortrait>
            <EventLargeImagePortrait>http://media.finnkino.fi/1012/Event_11881/portrait_large/The1517toParis_1080.jpg</EventLargeImagePortrait>
            <EventSmallImageLandscape>http://media.finnkino.fi/1012/Event_11881/landscape_small/The1517toParis_444.jpg</EventSmallImageLandscape>
            <EventLargeImageLandscape>https://media.finnkino.fi/1012/Event_11881/landscape_large/BookClub_670_kke.jpg</EventLargeImageLandscape>
        </Images>
        <Videos>
            <EventVideo>
                <Title>Katso traileri</Title>
                <Location>oFa4C6OcuM4</Location>
                <ThumbnailLocation />
                <MediaResourceSubType>EventTrailer</MediaResourceSubType>
                <MediaResourceFormat>YouTubeVideo</MediaResourceFormat>
            </EventVideo>
        </Videos>
        <Gallery>
          <GalleryImage>
            <Title />
            <Location>http://media.finnkino.fi/1012/Event_12007/gallery/Adrift_800a.jpg</Location>
            <ThumbnailLocation>http://media.finnkino.fi/1012/Event_12007/gallery/THUMB_Adrift_800a.jpg</ThumbnailLocation>
          </GalleryImage>
          <GalleryImage>
            <Title />
            <Location>http://media.finnkino.fi/1012/Event_12007/gallery/Adrift_800b.jpg</Location>
            <ThumbnailLocation>http://media.finnkino.fi/1012/Event_12007/gallery/THUMB_Adrift_800b.jpg</ThumbnailLocation>
          </GalleryImage>
          <GalleryImage>
            <Title />
            <Location>http://media.finnkino.fi/1012/Event_12007/gallery/Adrift_800c.jpg</Location>
            <ThumbnailLocation>http://media.finnkino.fi/1012/Event_12007/gallery/THUMB_Adrift_800c.jpg</ThumbnailLocation>
          </GalleryImage>
          <GalleryImage>
            <Title />
            <Location>http://media.finnkino.fi/1012/Event_12007/gallery/Adrift_800d.jpg</Location>
            <ThumbnailLocation>http://media.finnkino.fi/1012/Event_12007/gallery/THUMB_Adrift_800d.jpg</ThumbnailLocation>
          </GalleryImage>
          <GalleryImage>
            <Title />
            <Location>http://media.finnkino.fi/1012/Event_12007/gallery/Adrift_800e.jpg</Location>
            <ThumbnailLocation>http://media.finnkino.fi/1012/Event_12007/gallery/THUMB_Adrift_800e.jpg</ThumbnailLocation>
          </GalleryImage>
          <GalleryImage>
            <Title />
            <Location>http://media.finnkino.fi/1012/Event_12007/gallery/Adrift_800f.jpg</Location>
            <ThumbnailLocation>http://media.finnkino.fi/1012/Event_12007/gallery/THUMB_Adrift_800f.jpg</ThumbnailLocation>
          </GalleryImage>
          <GalleryImage>
            <Title />
            <Location>http://media.finnkino.fi/1012/Event_12007/gallery/Adrift_800g.jpg</Location>
            <ThumbnailLocation>http://media.finnkino.fi/1012/Event_12007/gallery/THUMB_Adrift_800g.jpg</ThumbnailLocation>
          </GalleryImage>
          <GalleryImage>
            <Title />
            <Location>http://media.finnkino.fi/1012/Event_12007/gallery/Adrift_800h.jpg</Location>
            <ThumbnailLocation>http://media.finnkino.fi/1012/Event_12007/gallery/THUMB_Adrift_800h.jpg</ThumbnailLocation>
          </GalleryImage>
        </Gallery>
        <Cast>
            <Actor>
                <FirstName>Anthony</FirstName>
                <LastName>Sadler</LastName>
            </Actor>
            <Actor>
                <FirstName>Alek</FirstName>
                <LastName>Skarlatos</LastName>
            </Actor>
            <Actor>
                <FirstName>Spencer</FirstName>
                <LastName>Stone</LastName>
            </Actor>
            <Actor>
                <FirstName>Jenna</FirstName>
                <LastName>Fischer</LastName>
            </Actor>
            <Actor>
                <FirstName>Judy</FirstName>
                <LastName>Greer</LastName>
            </Actor>
            <Actor>
                <FirstName>P.J.</FirstName>
                <LastName>Byrne</LastName>
            </Actor>
            <Actor>
                <FirstName>Tony</FirstName>
                <LastName>Hale</LastName>
            </Actor>
            <Actor>
                <FirstName>Thomas</FirstName>
                <LastName>Lennon</LastName>
            </Actor>
            <Actor>
                <FirstName>Paul-Mikél</FirstName>
                <LastName>Williams</LastName>
            </Actor>
            <Actor>
                <FirstName>Bryce</FirstName>
                <LastName>Gheisar</LastName>
            </Actor>
            <Actor>
                <FirstName>William</FirstName>
                <LastName>Jennings</LastName>
            </Actor>
        </Cast>
        <Directors>
            <Director>
                <FirstName>Clint</FirstName>
                <LastName>Eastwood</LastName>
            </Director>
        </Directors>
        <ContentDescriptors>
            <ContentDescriptor>
                <Name>Violence</Name>
                <ImageURL>https://media.finnkino.fi/images/content_Violence.png</ImageURL>
            </ContentDescriptor>
            <ContentDescriptor>
                <Name>Disturbing</Name>
                <ImageURL>https://media.finnkino.fi/images/content_Disturbing.png</ImageURL>
            </ContentDescriptor>
        </ContentDescriptors>
    </Event>
    <Event>
        <ID>302465</ID>
        <Title>95</Title>
        <OriginalTitle>95</OriginalTitle>
        <ProductionYear>2017</ProductionYear>
        <LengthInMinutes>107</LengthInMinutes>
        <dtLocalRelease>2017-12-25T00:00:00</dtLocalRelease>
        <Rating>Not yet rated</Rating>
        <RatingLabel>Not yet rated</RatingLabel>
        <RatingImageUrl>https://media.finnkino.fi/images/rating_large_Not yet rated.png</RatingImageUrl>
        <LocalDistributorName>SF Film Finland Oy</LocalDistributorName>
        <GlobalDistributorName>SF Film Finland Oy</GlobalDistributorName>
        <ProductionCompanies>-</ProductionCompanies>
        <EventType>Movie</EventType>
        <Genres>Draama, Kotimainen</Genres>
        <ShortSynopsis>Vuoden 1995 jääkiekon maailmanmestaruusviikonloppuun sijoittuva 95-elokuva kertoo toisiinsa limittyvien tarinoiden kautta siitä, miksi Suomesta tuli maailmanmestari ja miten se vaikutti koko kansakuntaan. 95 on osa virallista Suomi 100 -juhlavuoden ohjelmistoa.</ShortSynopsis>
        <Synopsis>Vuoden 1995 jääkiekon maailmanmestaruusviikonloppuun sijoittuva 95-elokuva kertoo toisiinsa limittyvien tarinoiden kautta siitä, miksi Suomesta tuli maailmanmestari ja miten se vaikutti koko kansakuntaan.

            95 on osa virallista Suomi 100 -juhlavuoden ohjelmistoa.

            Rooleissa: Curt Lindström – Jens Hulten, Hannu Aravirta – Kari-Pekka Toivonen, Heikki Riihiranta – Pekka Huotari, Saku Koivu – Jon-Jon Geitel, Ville Peltonen – Akseli Kouki, Jere Lehtinen – Kustaa Tuohimaa, Timo Jutila – Joel Hirvonen, Janne Ojanen – Oskari Ojanen, Marko Palo – Valtteri Honka, Marko Kiprusoff – Karlo Haapiainen, Raimo Helminen – Sebastian Rejman, Sami Kapanen – Mikko Laine, Esa Keskinen – Topias Hirvelä, Hannu Virta – Jarkko Järvinen, Mika Nieminen – Victor Paul, Antti Törmänen – Lauri Talvio, Jukka Tammi – Lauri Tilkanen, Raimo Summanen – Akseli Mattila, Ari Sulander – Henri Nyqvist, Mika Strömberg – Rasmus Tarkiainen, Erik Hämäläinen – Tommi Lipasti, Petteri Nummelin – Ronny Roslöf, Janne Niinimaa – Kimi Vilkkula, Juha Ylönen – Mikko Lindbom, Jarmo Myllys – Hannes Suominen, Tero Lehterä – Roman Tiinus</Synopsis>
        <EventURL>http://www.finnkino.fi/event/302465/title/95/</EventURL>
        <Images>
            <!-- Testing empty images element -->
            <SomeOtherImage>test</SomeOtherImage>
        </Images>
        <Videos>
            <EventVideo>
                <Title>Katso traileri</Title>
                <Location>AUlP8Sgzzk0</Location>
                <ThumbnailLocation />
                <MediaResourceSubType>EventTrailer</MediaResourceSubType>
                <MediaResourceFormat>YouTubeVideo</MediaResourceFormat>
            </EventVideo>
        </Videos>
        <Cast/>
        <Directors>
            <!-- Testing empty Directors element -->
            <Test>test</Test>
        </Directors>
        <ContentDescriptors>
            <ContentDescriptor>
                <Name>Disturbing</Name>
                <ImageURL>https://media.finnkino.fi/images/content_Disturbing.png</ImageURL>
            </ContentDescriptor>
        </ContentDescriptors>
    </Event>
    <Event>
        <ID>302478</ID>
        <Title>All the Money in the World</Title>
        <OriginalTitle>All the Money in the World</OriginalTitle>
        <ProductionYear>2017</ProductionYear>
        <LengthInMinutes>133</LengthInMinutes>
        <dtLocalRelease>2018-01-12T00:00:00</dtLocalRelease>
        <Rating>16</Rating>
        <RatingLabel>16</RatingLabel>
        <RatingImageUrl>https://media.finnkino.fi/images/rating_large_16.png</RatingImageUrl>
        <LocalDistributorName>SF Film Finland Oy</LocalDistributorName>
        <GlobalDistributorName>SF Film Finland Oy</GlobalDistributorName>
        <ProductionCompanies>-</ProductionCompanies>
        <EventType>Movie</EventType>
        <Genres>Draama, Jännitys</Genres>
        <ShortSynopsis>Elokuva kertoo 16-vuotiaan John Paul Getty III:n (Charlie Plummer) kidnappauksesta ja hänen omistautuneen äitinsä Gailin (Michelle Williams) epätoivoisesta yrityksestä saada poikansa miljonääri isoisä (Christopher Plummer) maksamaan lunnaat.</ShortSynopsis>
        <Synopsis>Elokuva kertoo 16-vuotiaan John Paul Getty III:n (Charlie Plummer) kidnappauksesta ja hänen omistautuneen äitinsä Gailin (Michelle Williams) epätoivoisesta yrityksestä saada poikansa miljonääri isoisä (Christopher Plummer) maksamaan lunnaat. Getty vanhemman kieltäytyessä, ja sieppaajien muuttuessa yhä epävakaammiksi ja brutaalimmaksi, Gail yrittää vedota häneen. Poikansa elämän ollessa vaakalaudalla, Gailista ja Gettyn neuvonantajasta (Mark Wahlberg) muodostuu epätavalliset liittolaiset kilpailussa aikaa vastaan. Kilpailussa, joka lopulta paljastaa rakkauden todellisen arvon suhteessa rahaan.</Synopsis>
        <EventURL>http://www.finnkino.fi/event/302478/title/all_the_money_in_the_world/</EventURL>

        <!-- Testing event without "Images" tag at all -->

        <Videos>
            <EventVideo>
                <Title>Katso traileri</Title>
                <Location>GKc9LWtlAW4</Location>
                <ThumbnailLocation />
                <MediaResourceSubType>EventTrailer</MediaResourceSubType>
                <MediaResourceFormat>YouTubeVideo</MediaResourceFormat>
            </EventVideo>
        </Videos>
        <Cast>
            <Actor>
                <FirstName>Michelle</FirstName>
                <LastName>Williams</LastName>
            </Actor>
            <Actor>
                <FirstName>Mark</FirstName>
                <LastName>Wahlberg</LastName>
            </Actor>
            <Actor>
                <FirstName>Christopher</FirstName>
                <LastName>Plummer</LastName>
            </Actor>
            <Actor>
                <FirstName>Romain</FirstName>
                <LastName>Duris</LastName>
            </Actor>
            <Actor>
                <FirstName>Charlie</FirstName>
                <LastName>Plummer</LastName>
            </Actor>
            <Actor>
                <FirstName>Timothy</FirstName>
                <LastName>Hutton</LastName>
            </Actor>
            <Actor>
                <FirstName>Dan</FirstName>
                <LastName>Friedkin</LastName>
            </Actor>
        </Cast>
        <Directors>
            <Director>
                <FirstName>Ridley</FirstName>
                <LastName>Scott</LastName>
            </Director>
            <Director>
                <FirstName>Clint</FirstName>
                <LastName>Eastwood</LastName>
            </Director>
        </Directors>
        <ContentDescriptors>
            <ContentDescriptor>
                <Name>Violence</Name>
                <ImageURL>https://media.finnkino.fi/images/content_Violence.png</ImageURL>
            </ContentDescriptor>
            <ContentDescriptor>
                <Name>Disturbing</Name>
                <ImageURL>https://media.finnkino.fi/images/content_Disturbing.png</ImageURL>
            </ContentDescriptor>
        </ContentDescriptors>
    </Event>
</Events>''';

