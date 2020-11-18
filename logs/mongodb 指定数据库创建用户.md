> > use db_xqds_opc
> > switched to db db_xqds_opc
>
> > db.createUser({user:"root",pwd:"root_xqds",roles:[{role:"readWrite",db:"db_xqds_opc"},{role:"dbOwner",db:"db_xqds_opc"}]});
> > Successfully added user: {
> >    "user" : "root",
> >    "roles" : [
> >            {
> >                    "role" : "readWrite",
> >                    "db" : "db_xqds_opc"
> >            },
> >            {
> >                    "role" : "dbOwner",
> >                    "db" : "db_xqds_opc"
> >            }
> >    ]
> > }
>
> > db.auth("root","root_xqds")
> > 1