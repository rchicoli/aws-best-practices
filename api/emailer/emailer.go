package emailer

// {
//     "address": "contato@pousadaareias.com.br",
//     "username": "contato",
//     "domain": "pousadaareias.com.br",
//     "md5Hash": "3b7795c84ae1ba611a2b3e8666a5466f",
//     "validFormat": true,
//     "deliverable": true,
//     "fullInbox": false,
//     "hostExists": true,
//     "catchAll": false,
//     "gravatar": false,
//     "disposable": false,
//     "free": false
// }

// Body ...
type Body struct {
	Firstname string `json:"firstname"`
	Lastname  string `json:"lastname"`
	Email     string `json:"email"`
}
