package emailer

import (
	"errors"
	"net"
	"regexp"
	"strings"
)

var (

	// ErrInvalidFormat ...
	ErrInvalidFormat = errors.New("invalid format")

	// ErrUnresolvableHost ...
	ErrUnresolvableHost = errors.New("unresolvable host")

	userRegexp = regexp.MustCompile("^[a-zA-Z0-9!#$%&'*+/=?^_`{|}~.-]+$")
	hostRegexp = regexp.MustCompile("^[^\\s]+\\.[^\\s]+$")
	// As per RFC 5332 secion 3.2.3: https://tools.ietf.org/html/rfc5322#section-3.2.3
	// Dots are not allowed in the beginning, end or in occurances of more than 1 in the email address

	// https://stackoverflow.com/questions/2049502/what-characters-are-allowed-in-an-email-address
	// addr-spec   =  local-part "@" domain        ; global address
	// local-part  =  word *("." word)             ; uninterpreted
	// 											   ; case-preserved
	// 	domain      =  sub-domain *("." sub-domain)
	// 	sub-domain  =  domain-ref / domain-literal
	// 	domain-ref  =  atom                         ; symbolic reference

	//  And as usual, Wikipedia has a decent article on email addresses:
	// 	The local-part of the email address may use any of these ASCII characters:

	// 	uppercase and lowercase Latin letters A to Z and a to z;
	// 	digits 0 to 9;
	// 	special characters !#$%&'*+-/=?^_`{|}~;
	// 	dot ., provided that it is not the first or last character unless quoted, and provided also that it does not appear consecutively unless quoted (e.g. John..Doe@example.com is not allowed but "John..Doe"@example.com is allowed);
	// 	space and "(),:;<>@[\] characters are allowed with restrictions (they are only allowed inside a quoted string, as described in the paragraph below, and in addition, a backslash or double-quote must be preceded by a backslash);
	// 	comments are allowed with parentheses at either end of the local-part; e.g. john.smith(comment)@example.com and (comment)john.smith@example.com are both equivalent to john.smith@example.com.

	userDotRegexp = regexp.MustCompile(`(^\.)|(\.$)|([.]{2,})`)

	emailRegexp = regexp.MustCompile("^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$")
)

// Validate checks format of a given email and resolves its host name.
func Validate(email string) error {
	// if len(email) < 6 || len(email) > 254 {
	// 	return ErrInvalidFormat
	// }

	at := strings.LastIndex(email, "@")
	if at <= 0 || at > len(email)-3 {
		return ErrInvalidFormat
	}

	user := email[:at]
	host := email[at+1:]
	if at <= 0 || at > len(email)-3 {
		return ErrInvalidFormat
	}

	if userDotRegexp.MatchString(user) || !userRegexp.MatchString(user) || !hostRegexp.MatchString(host) {
		return ErrInvalidFormat
	}

	// if emailRegexp.MatchString(email) {
	// 	return ErrInvalidFormat
	// }

	switch host {
	case "localhost", "example.com":
		return nil
	}

	if _, err := net.LookupMX(host); err != nil {
		if _, err := net.LookupIP(host); err != nil {
			// Only fail if both MX and A records are missing - any of the
			// two is enough for an email to be deliverable
			return err
			// return ErrUnresolvableHost
		}
	}

	return nil
}

// Normalize normalizes email address.
func Normalize(email string) string {
	// Trim whitespaces.
	email = strings.TrimSpace(email)

	// Trim extra dot in hostname.
	email = strings.TrimRight(email, ".")

	// Lowercase.
	email = strings.ToLower(email)

	return email
}
