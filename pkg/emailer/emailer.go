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

	userDotRegexp = regexp.MustCompile(`(^\.)|(\.$)|([.]{2,})`)

	emailRegexp = regexp.MustCompile("^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$")
)

// Validate checks format of a given email and resolves its host name.
func Validate(email string) error {
	// if len(email) < 6 || len(email) > 254 {
	// 	return ErrInvalidFormat
	// }

	user, host, err := ParseEmail(email)
	if err != nil {
		return err
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

func ParseEmail(email string) (string, string, error) {
	i := strings.LastIndexByte(email, '@')
	if i <= 0 {
		return "", "", ErrInvalidFormat
	}

	return email[:i], email[i+1:], nil
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
