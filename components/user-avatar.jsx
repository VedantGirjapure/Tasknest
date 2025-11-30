import React from "react";
import { Avatar, AvatarFallback, AvatarImage } from "./ui/avatar";

const UserAvatar = ({ user }) => {
  // Handle null/undefined or "null null" names
  const getUserName = () => {
    if (!user) return "Unassigned";
    if (!user.name || user.name.trim() === "" || user.name === "null null" || user.name === "null" || user.name === "undefined undefined") {
      // Try to get name from email if available
      if (user.email) {
        return user.email.split("@")[0];
      }
      return "Unassigned";
    }
    return user.name;
  };

  const displayName = getUserName();
  const initials = displayName !== "Unassigned" 
    ? displayName.split(" ").map(n => n[0]).join("").toUpperCase().slice(0, 2)
    : "?";

  return (
    <div className="flex items-center space-x-2 w-full">
      <Avatar className="h-6 w-6">
        <AvatarImage src={user?.imageUrl} alt={displayName} />
        <AvatarFallback className="capitalize">
          {initials}
        </AvatarFallback>
      </Avatar>
      <span className="text-xs text-gray-500">
        {displayName}
      </span>
    </div>
  );
};

export default UserAvatar;
